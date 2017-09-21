defmodule Membrane.Element.MPEGAudioParse.Parser do
  use Membrane.Element.Base.Filter
  use Membrane.Mixins.Log, tags: :membrane_element_mpegaudioparse
  alias Membrane.Caps.Audio.MPEG

  @mpeg_header_size 4

  def_known_sink_pads %{
    :sink => {:always, {:pull, demand_in: :bytes}, :any}
  }

  def_known_source_pads %{
    :source => {:always, :pull, :any}
  }


  # Private API

  @doc false
  def handle_init(_) do
    {:ok, %{
      queue: << >>,
      caps: nil,
      frame_size: @mpeg_header_size,
    }}
  end

  def handle_demand(:source, n_bufs, :buffers, _params, %{queue: queue, frame_size: frame_size} = state) do
    demanded_bytes = frame_size * n_bufs - byte_size(queue) + @mpeg_header_size
    {{:ok, demand: {:sink, demanded_bytes}}, state}
  end

  def handle_process1(:sink, %Membrane.Buffer{payload: payload}, _params, %{queue: queue, caps: caps, frame_size: frame_size} = state) do
    data = (queue <> payload) |> skip_to_frame()
    case do_parse(data, caps, frame_size, []) do
      {:ok, commands, new_queue, new_caps, new_frame_size} ->
        {{:ok, commands |> Enum.reverse}, %{state | queue: new_queue, caps: new_caps, frame_size: new_frame_size}}
    end
  end

  defp do_parse(<< >>, previous_caps, prev_frame_size, acc), do: {:ok, acc, << >>, previous_caps, prev_frame_size}

  # We have at least header.
  defp do_parse(payload, previous_caps, prev_frame_size, acc) when byte_size(payload) >= @mpeg_header_size do
    << 0b11111111111   :: size(11),
       version         :: 2-bitstring,
       layer           :: 2-bitstring,
       crc_enabled     :: 1-bitstring,
       bitrate         :: 4-bitstring,
       sample_rate     :: 2-bitstring,
       padding_enabled :: 1-bitstring,
       private         :: 1-bitstring,
       channel_mode    :: 2-bitstring,
       mode_extension  :: 2-bitstring,
       copyright       :: 1-bitstring,
       original        :: 1-bitstring,
       emphasis_mode   :: 2-bitstring,
       rest :: bitstring >> = payload

    version         = parse_version(version)
    layer           = parse_layer(layer)
    channel_mode    = parse_channel_mode(channel_mode)
    crc_enabled     = parse_crc_enabled(crc_enabled)
    bitrate         = parse_bitrate(bitrate, version, layer)
    sample_rate     = parse_sample_rate(sample_rate, version)
    padding_enabled = parse_padding_enabled(padding_enabled)

    caps =
      %MPEG{
        version: version,
        layer: layer,
        crc_enabled: crc_enabled,
        bitrate: bitrate,
        sample_rate: sample_rate,
        padding_enabled: padding_enabled,
        private: parse_private(private),
        channel_mode: channel_mode,
        mode_extension: parse_mode_extension(mode_extension, channel_mode),
        copyright: parse_copyright(copyright),
        original: parse_original(original),
        emphasis_mode: parse_emphasis_mode(emphasis_mode),
      }

    invalid = caps |> Map.values |> Enum.any?(fn val -> val in [:invalid, :free] end)

    if invalid do
      payload |> force_skip_to_frame |> do_parse(previous_caps, prev_frame_size, acc)
    else
      frame_size = if padding_enabled do
        ((144 * bitrate * 1000) |> div(sample_rate)) + 1
      else
        (144 * bitrate * 1000) |> div(sample_rate)
      end

      if byte_size(payload) < frame_size do
        {:ok, acc, payload, previous_caps, frame_size}
      else
        << frame_payload :: size(frame_size)-binary, rest :: bitstring >> = payload
        if byte_size(rest) < 11 or pre_check(rest) do
          acc = if previous_caps != caps do
            [{:caps, {:source, caps}}|acc]
          else
            acc
          end

          frame_buffer = {:buffer, {:source, %Membrane.Buffer{payload: frame_payload}}}
          do_parse(rest, caps, frame_size, [frame_buffer|acc])
        else
          # Next frame is not valid, so we got the frame size wrong. It means that we parsed random data
          # that fitted MPEG Audio Header by accident. Let's look for another frame.
          payload |> force_skip_to_frame |> do_parse(previous_caps, prev_frame_size, acc)
        end
      end
    end
  end

  defp do_parse(payload, previous_caps, prev_frame_size, acc) do
    {:ok, acc, payload, previous_caps, prev_frame_size}
  end

  defp pre_check(<< 0b11111111111 :: size(11), _ :: bitstring >>), do: true
  defp pre_check(_), do: false

  defp force_skip_to_frame(<< >>), do: << >>
  defp force_skip_to_frame(payload) do
    payload |> binary_part(1, byte_size(payload) - 1) |> skip_to_frame
  end

  defp skip_to_frame(<< >>), do: << >>
  defp skip_to_frame(<< 0b11111111111 :: size(11), _ :: bitstring >> = frame), do: frame
  defp skip_to_frame(payload) do
    # Skip one byte to avoid infinite loop
    next_payload = payload |> binary_part(1, byte_size(payload) - 1)
    size = byte_size(next_payload)
    case next_payload |> :binary.match(<<0xff>>) do
      {pos, _len} ->
        debug("Dropped bytes: #{inspect binary_part(payload, 0, pos + 1)}")
        next_payload |> binary_part(pos, size - pos)
      :nomatch   -> << >>
    end
    |> skip_to_frame()
  end

  defp parse_version(<< 0b00 :: size(2) >>), do: :v2_5
  defp parse_version(<< 0b10 :: size(2) >>), do: :v2
  defp parse_version(<< 0b11 :: size(2) >>), do: :v1
  defp parse_version(_), do: :invalid


  defp parse_layer(<< 0b01 :: size(2) >>), do: :layer3
  defp parse_layer(<< 0b10 :: size(2) >>), do: :layer2
  defp parse_layer(<< 0b11 :: size(2) >>), do: :layer1
  defp parse_layer(_), do: :invalid


  defp parse_crc_enabled(<< 1 :: 1>>), do: true
  defp parse_crc_enabled(<< 0 :: 1>>), do: false


  defp parse_bitrate(<< 0b0000 :: size(4) >>, _, _), do: :free

  defp parse_bitrate(<< 0b0001 :: size(4) >>, :v1, :layer1), do: 32
  defp parse_bitrate(<< 0b0010 :: size(4) >>, :v1, :layer1), do: 64
  defp parse_bitrate(<< 0b0011 :: size(4) >>, :v1, :layer1), do: 96
  defp parse_bitrate(<< 0b0100 :: size(4) >>, :v1, :layer1), do: 128
  defp parse_bitrate(<< 0b0101 :: size(4) >>, :v1, :layer1), do: 160
  defp parse_bitrate(<< 0b0110 :: size(4) >>, :v1, :layer1), do: 192
  defp parse_bitrate(<< 0b0111 :: size(4) >>, :v1, :layer1), do: 224
  defp parse_bitrate(<< 0b1000 :: size(4) >>, :v1, :layer1), do: 256
  defp parse_bitrate(<< 0b1001 :: size(4) >>, :v1, :layer1), do: 288
  defp parse_bitrate(<< 0b1010 :: size(4) >>, :v1, :layer1), do: 320
  defp parse_bitrate(<< 0b1011 :: size(4) >>, :v1, :layer1), do: 352
  defp parse_bitrate(<< 0b1100 :: size(4) >>, :v1, :layer1), do: 384
  defp parse_bitrate(<< 0b1101 :: size(4) >>, :v1, :layer1), do: 416
  defp parse_bitrate(<< 0b1110 :: size(4) >>, :v1, :layer1), do: 448

  defp parse_bitrate(<< 0b0001 :: size(4) >>, :v1, :layer2), do: 32
  defp parse_bitrate(<< 0b0010 :: size(4) >>, :v1, :layer2), do: 48
  defp parse_bitrate(<< 0b0011 :: size(4) >>, :v1, :layer2), do: 56
  defp parse_bitrate(<< 0b0100 :: size(4) >>, :v1, :layer2), do: 64
  defp parse_bitrate(<< 0b0101 :: size(4) >>, :v1, :layer2), do: 80
  defp parse_bitrate(<< 0b0110 :: size(4) >>, :v1, :layer2), do: 96
  defp parse_bitrate(<< 0b0111 :: size(4) >>, :v1, :layer2), do: 112
  defp parse_bitrate(<< 0b1000 :: size(4) >>, :v1, :layer2), do: 128
  defp parse_bitrate(<< 0b1001 :: size(4) >>, :v1, :layer2), do: 160
  defp parse_bitrate(<< 0b1010 :: size(4) >>, :v1, :layer2), do: 192
  defp parse_bitrate(<< 0b1011 :: size(4) >>, :v1, :layer2), do: 224
  defp parse_bitrate(<< 0b1100 :: size(4) >>, :v1, :layer2), do: 256
  defp parse_bitrate(<< 0b1101 :: size(4) >>, :v1, :layer2), do: 320
  defp parse_bitrate(<< 0b1110 :: size(4) >>, :v1, :layer2), do: 384

  defp parse_bitrate(<< 0b0001 :: size(4) >>, :v1, :layer3), do: 32
  defp parse_bitrate(<< 0b0010 :: size(4) >>, :v1, :layer3), do: 40
  defp parse_bitrate(<< 0b0011 :: size(4) >>, :v1, :layer3), do: 48
  defp parse_bitrate(<< 0b0100 :: size(4) >>, :v1, :layer3), do: 56
  defp parse_bitrate(<< 0b0101 :: size(4) >>, :v1, :layer3), do: 64
  defp parse_bitrate(<< 0b0110 :: size(4) >>, :v1, :layer3), do: 80
  defp parse_bitrate(<< 0b0111 :: size(4) >>, :v1, :layer3), do: 96
  defp parse_bitrate(<< 0b1000 :: size(4) >>, :v1, :layer3), do: 112
  defp parse_bitrate(<< 0b1001 :: size(4) >>, :v1, :layer3), do: 128
  defp parse_bitrate(<< 0b1010 :: size(4) >>, :v1, :layer3), do: 160
  defp parse_bitrate(<< 0b1011 :: size(4) >>, :v1, :layer3), do: 192
  defp parse_bitrate(<< 0b1100 :: size(4) >>, :v1, :layer3), do: 224
  defp parse_bitrate(<< 0b1101 :: size(4) >>, :v1, :layer3), do: 256
  defp parse_bitrate(<< 0b1110 :: size(4) >>, :v1, :layer3), do: 320

  defp parse_bitrate(<< 0b0001 :: size(4) >>, :v2, :layer1), do: 32
  defp parse_bitrate(<< 0b0010 :: size(4) >>, :v2, :layer1), do: 48
  defp parse_bitrate(<< 0b0011 :: size(4) >>, :v2, :layer1), do: 56
  defp parse_bitrate(<< 0b0100 :: size(4) >>, :v2, :layer1), do: 64
  defp parse_bitrate(<< 0b0101 :: size(4) >>, :v2, :layer1), do: 80
  defp parse_bitrate(<< 0b0110 :: size(4) >>, :v2, :layer1), do: 96
  defp parse_bitrate(<< 0b0111 :: size(4) >>, :v2, :layer1), do: 112
  defp parse_bitrate(<< 0b1000 :: size(4) >>, :v2, :layer1), do: 128
  defp parse_bitrate(<< 0b1001 :: size(4) >>, :v2, :layer1), do: 144
  defp parse_bitrate(<< 0b1010 :: size(4) >>, :v2, :layer1), do: 160
  defp parse_bitrate(<< 0b1011 :: size(4) >>, :v2, :layer1), do: 176
  defp parse_bitrate(<< 0b1100 :: size(4) >>, :v2, :layer1), do: 192
  defp parse_bitrate(<< 0b1101 :: size(4) >>, :v2, :layer1), do: 224
  defp parse_bitrate(<< 0b1110 :: size(4) >>, :v2, :layer1), do: 256

  defp parse_bitrate(<< 0b0001 :: size(4) >>, :v2, :layer2), do: 8
  defp parse_bitrate(<< 0b0010 :: size(4) >>, :v2, :layer2), do: 16
  defp parse_bitrate(<< 0b0011 :: size(4) >>, :v2, :layer2), do: 24
  defp parse_bitrate(<< 0b0100 :: size(4) >>, :v2, :layer2), do: 32
  defp parse_bitrate(<< 0b0101 :: size(4) >>, :v2, :layer2), do: 40
  defp parse_bitrate(<< 0b0110 :: size(4) >>, :v2, :layer2), do: 48
  defp parse_bitrate(<< 0b0111 :: size(4) >>, :v2, :layer2), do: 56
  defp parse_bitrate(<< 0b1000 :: size(4) >>, :v2, :layer2), do: 64
  defp parse_bitrate(<< 0b1001 :: size(4) >>, :v2, :layer2), do: 80
  defp parse_bitrate(<< 0b1010 :: size(4) >>, :v2, :layer2), do: 96
  defp parse_bitrate(<< 0b1011 :: size(4) >>, :v2, :layer2), do: 112
  defp parse_bitrate(<< 0b1100 :: size(4) >>, :v2, :layer2), do: 128
  defp parse_bitrate(<< 0b1101 :: size(4) >>, :v2, :layer2), do: 144
  defp parse_bitrate(<< 0b1110 :: size(4) >>, :v2, :layer2), do: 160

  defp parse_bitrate(<< 0b0001 :: size(4) >>, :v2, :layer3), do: 8
  defp parse_bitrate(<< 0b0010 :: size(4) >>, :v2, :layer3), do: 16
  defp parse_bitrate(<< 0b0011 :: size(4) >>, :v2, :layer3), do: 24
  defp parse_bitrate(<< 0b0100 :: size(4) >>, :v2, :layer3), do: 32
  defp parse_bitrate(<< 0b0101 :: size(4) >>, :v2, :layer3), do: 40
  defp parse_bitrate(<< 0b0110 :: size(4) >>, :v2, :layer3), do: 48
  defp parse_bitrate(<< 0b0111 :: size(4) >>, :v2, :layer3), do: 56
  defp parse_bitrate(<< 0b1000 :: size(4) >>, :v2, :layer3), do: 64
  defp parse_bitrate(<< 0b1001 :: size(4) >>, :v2, :layer3), do: 80
  defp parse_bitrate(<< 0b1010 :: size(4) >>, :v2, :layer3), do: 96
  defp parse_bitrate(<< 0b1011 :: size(4) >>, :v2, :layer3), do: 112
  defp parse_bitrate(<< 0b1100 :: size(4) >>, :v2, :layer3), do: 128
  defp parse_bitrate(<< 0b1101 :: size(4) >>, :v2, :layer3), do: 144
  defp parse_bitrate(<< 0b1110 :: size(4) >>, :v2, :layer3), do: 160

  defp parse_bitrate(<< 0b0001 :: size(4) >>, :v2_5, :layer1), do: 32
  defp parse_bitrate(<< 0b0010 :: size(4) >>, :v2_5, :layer1), do: 48
  defp parse_bitrate(<< 0b0011 :: size(4) >>, :v2_5, :layer1), do: 56
  defp parse_bitrate(<< 0b0100 :: size(4) >>, :v2_5, :layer1), do: 64
  defp parse_bitrate(<< 0b0101 :: size(4) >>, :v2_5, :layer1), do: 80
  defp parse_bitrate(<< 0b0110 :: size(4) >>, :v2_5, :layer1), do: 96
  defp parse_bitrate(<< 0b0111 :: size(4) >>, :v2_5, :layer1), do: 112
  defp parse_bitrate(<< 0b1000 :: size(4) >>, :v2_5, :layer1), do: 128
  defp parse_bitrate(<< 0b1001 :: size(4) >>, :v2_5, :layer1), do: 144
  defp parse_bitrate(<< 0b1010 :: size(4) >>, :v2_5, :layer1), do: 160
  defp parse_bitrate(<< 0b1011 :: size(4) >>, :v2_5, :layer1), do: 176
  defp parse_bitrate(<< 0b1100 :: size(4) >>, :v2_5, :layer1), do: 192
  defp parse_bitrate(<< 0b1101 :: size(4) >>, :v2_5, :layer1), do: 224
  defp parse_bitrate(<< 0b1110 :: size(4) >>, :v2_5, :layer1), do: 256

  defp parse_bitrate(<< 0b0001 :: size(4) >>, :v2_5, :layer2), do: 8
  defp parse_bitrate(<< 0b0010 :: size(4) >>, :v2_5, :layer2), do: 16
  defp parse_bitrate(<< 0b0011 :: size(4) >>, :v2_5, :layer2), do: 24
  defp parse_bitrate(<< 0b0100 :: size(4) >>, :v2_5, :layer2), do: 32
  defp parse_bitrate(<< 0b0101 :: size(4) >>, :v2_5, :layer2), do: 40
  defp parse_bitrate(<< 0b0110 :: size(4) >>, :v2_5, :layer2), do: 48
  defp parse_bitrate(<< 0b0111 :: size(4) >>, :v2_5, :layer2), do: 56
  defp parse_bitrate(<< 0b1000 :: size(4) >>, :v2_5, :layer2), do: 64
  defp parse_bitrate(<< 0b1001 :: size(4) >>, :v2_5, :layer2), do: 80
  defp parse_bitrate(<< 0b1010 :: size(4) >>, :v2_5, :layer2), do: 96
  defp parse_bitrate(<< 0b1011 :: size(4) >>, :v2_5, :layer2), do: 112
  defp parse_bitrate(<< 0b1100 :: size(4) >>, :v2_5, :layer2), do: 128
  defp parse_bitrate(<< 0b1101 :: size(4) >>, :v2_5, :layer2), do: 144
  defp parse_bitrate(<< 0b1110 :: size(4) >>, :v2_5, :layer2), do: 160

  defp parse_bitrate(<< 0b0001 :: size(4) >>, :v2_5, :layer3), do: 8
  defp parse_bitrate(<< 0b0010 :: size(4) >>, :v2_5, :layer3), do: 16
  defp parse_bitrate(<< 0b0011 :: size(4) >>, :v2_5, :layer3), do: 24
  defp parse_bitrate(<< 0b0100 :: size(4) >>, :v2_5, :layer3), do: 32
  defp parse_bitrate(<< 0b0101 :: size(4) >>, :v2_5, :layer3), do: 40
  defp parse_bitrate(<< 0b0110 :: size(4) >>, :v2_5, :layer3), do: 48
  defp parse_bitrate(<< 0b0111 :: size(4) >>, :v2_5, :layer3), do: 56
  defp parse_bitrate(<< 0b1000 :: size(4) >>, :v2_5, :layer3), do: 64
  defp parse_bitrate(<< 0b1001 :: size(4) >>, :v2_5, :layer3), do: 80
  defp parse_bitrate(<< 0b1010 :: size(4) >>, :v2_5, :layer3), do: 96
  defp parse_bitrate(<< 0b1011 :: size(4) >>, :v2_5, :layer3), do: 112
  defp parse_bitrate(<< 0b1100 :: size(4) >>, :v2_5, :layer3), do: 128
  defp parse_bitrate(<< 0b1101 :: size(4) >>, :v2_5, :layer3), do: 144
  defp parse_bitrate(<< 0b1110 :: size(4) >>, :v2_5, :layer3), do: 160

  defp parse_bitrate(_, _, _), do: :invalid

  defp parse_sample_rate(<< 0b00 :: size(2) >>, :v1), do: 44100
  defp parse_sample_rate(<< 0b01 :: size(2) >>, :v1), do: 48000
  defp parse_sample_rate(<< 0b10 :: size(2) >>, :v1), do: 32000

  defp parse_sample_rate(<< 0b00 :: size(2) >>, :v2), do: 22050
  defp parse_sample_rate(<< 0b01 :: size(2) >>, :v2), do: 24000
  defp parse_sample_rate(<< 0b10 :: size(2) >>, :v2), do: 16000

  defp parse_sample_rate(<< 0b00 :: size(2) >>, :v2_5), do: 11050
  defp parse_sample_rate(<< 0b01 :: size(2) >>, :v2_5), do: 12000
  defp parse_sample_rate(<< 0b10 :: size(2) >>, :v2_5), do: 8000
  defp parse_sample_rate(_, _), do: :invalid


  defp parse_padding_enabled(<< 1 :: 1 >>), do: true
  defp parse_padding_enabled(<< 0 :: 1 >>), do: false


  defp parse_private(<< 1 :: 1 >>), do: true
  defp parse_private(<< 0 :: 1 >>), do: false


  defp parse_channel_mode(<< 0b00 :: size(2) >>), do: :stereo
  defp parse_channel_mode(<< 0b01 :: size(2) >>), do: :joint_stereo
  defp parse_channel_mode(<< 0b10 :: size(2) >>), do: :dual_channel
  defp parse_channel_mode(<< 0b11 :: size(2) >>), do: :single_channel
  defp parse_channel_mode(_), do: :invalid


  defp parse_mode_extension(_, :stereo), do: nil
  defp parse_mode_extension(_, :dual_channel), do: nil
  defp parse_mode_extension(_, :single_channel), do: nil

  defp parse_mode_extension(<< 0b00 :: size(2) >>, :joint_stereo), do: :mode0
  defp parse_mode_extension(<< 0b01 :: size(2) >>, :joint_stereo), do: :mode1
  defp parse_mode_extension(<< 0b10 :: size(2) >>, :joint_stereo), do: :mode2
  defp parse_mode_extension(<< 0b11 :: size(2) >>, :joint_stereo), do: :mode3
  defp parse_mode_extension(_, _), do: :invalid


  defp parse_original(<< 1 :: 1 >>), do: true
  defp parse_original(<< 0 :: 1 >>), do: false


  defp parse_copyright(<< 1 :: 1 >>), do: true
  defp parse_copyright(<< 0 :: 1 >>), do: false


  defp parse_emphasis_mode(<< 0b00 :: size(2) >>), do: :none
  defp parse_emphasis_mode(<< 0b01 :: size(2) >>), do: :emphasis_50_15
  defp parse_emphasis_mode(<< 0b11 :: size(2) >>), do: :ccit_j_17
  defp parse_emphasis_mode(_), do: :invalid
end
