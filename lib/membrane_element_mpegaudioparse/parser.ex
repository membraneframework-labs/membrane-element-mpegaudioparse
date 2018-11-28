defmodule Membrane.Element.MPEGAudioParse.Parser do
  @moduledoc """
  Parses and splits into frames MPEG-1 Part 3 audio streams

  See `options/0` for available options
  """
  use Membrane.Element.Base.Filter
  use Membrane.Log, tags: :membrane_element_mpegaudioparse
  alias Membrane.Caps.Audio.MPEG
  import __MODULE__.Helper

  @mpeg_header_size MPEG.header_size()

  def_input_pads input: [caps: :any, demand_unit: :bytes]

  def_output_pads output: [caps: MPEG]

  def_options skip_until_frame: [
                type: :boolean,
                description: """
                When set to true the parser will skip bytes until it finds a valid frame.
                Otherwise invalid frames will cause an error.
                """,
                default: false
              ]

  @impl true
  def handle_init(%__MODULE__{skip_until_frame: skip_flag}) do
    {:ok,
     %{
       queue: <<>>,
       caps: nil,
       skip_until_frame: skip_flag,
       # Start with the smallest MPEG frame
       frame_size:
         MPEG.frame_size(%MPEG{
           version: :v1,
           layer: :layer1,
           bitrate: 32,
           sample_rate: 48_000,
           padding_enabled: false
         })
     }}
  end

  @impl true
  def handle_demand(:output, n_bufs, :buffers, _ctx, state) do
    %{queue: queue, frame_size: frame_size} = state
    # try to demand enough bytes for `n_bufs` frames + header of the next frame
    # to calculate its size. The estimation may not be 100% accurate if the frame size
    # varies between frames (and usually it does because the padding is present
    # only in some of the frames)
    demanded_bytes = frame_size * n_bufs - byte_size(queue) + @mpeg_header_size

    {{:ok, demand: {:input, demanded_bytes}}, state}
  end

  @impl true
  def handle_process(:input, %Membrane.Buffer{payload: payload}, ctx, state) do
    %{queue: queue, frame_size: frame_size, skip_until_frame: skip_flag} = state
    caps = ctx.pads.output.caps

    case do_parse(queue <> payload, [], caps, frame_size, skip_flag) do
      {:ok, new_queue, actions, _caps, new_frame_size} ->
        {{:ok, actions}, %{state | queue: new_queue, frame_size: new_frame_size}}

      {:error, reason} ->
        raise """
        Error while parsing frame. You may consider using "skip_to_frame" option to prevent this error.
        Reason: #{inspect(reason, pretty: true)}
        """
    end
  end

  @impl true
  def handle_caps(:input, _caps, _ctx, state), do: {:ok, state}

  # We have at least header.
  defp do_parse(payload, acc, previous_caps, prev_frame_size, skip_flag)
       when byte_size(payload) >= @mpeg_header_size do
    with {:ok, caps} <- parse_header(payload),
         frame_size = MPEG.frame_size(caps),
         :full_frame <- verify_payload_size(payload, frame_size),
         <<frame_payload::size(frame_size)-binary, rest::bitstring>> = payload,
         :ok <- validate_frame_start(rest) do
      acc =
        if previous_caps != caps do
          [{:caps, {:output, caps}} | acc]
        else
          acc
        end

      frame_buffer = {:buffer, {:output, %Membrane.Buffer{payload: frame_payload}}}
      do_parse(rest, [frame_buffer | acc], caps, frame_size, skip_flag)
    else
      {:error, :unsupported} ->
        {:error, {:unsupported_frame, payload}}

      {:error, :invalid} ->
        if skip_flag do
          payload
          |> force_skip_to_frame()
          |> do_parse(acc, previous_caps, prev_frame_size, skip_flag)
        else
          {:error, {:invalid_frame, payload}}
        end

      {:partial_frame, frame_size} ->
        acc = [{:redemand, :output} | acc] |> Enum.reverse()
        {:ok, payload, acc, previous_caps, frame_size}
    end
  end

  defp do_parse(payload, acc, previous_caps, prev_frame_size, _) do
    acc = [{:redemand, :output} | acc] |> Enum.reverse()
    {:ok, payload, acc, previous_caps, prev_frame_size}
  end

  defp verify_payload_size(payload, frame_size) do
    if byte_size(payload) >= frame_size do
      :full_frame
    else
      {:partial_frame, frame_size}
    end
  end

  # Check if argument can be a valid frame. If there's not enough bytes to perform check, assume it's ok
  defp validate_frame_start(<<0b11111111111::size(11), _::bitstring>>), do: :ok
  defp validate_frame_start(<<_::size(11), _::bitstring>>), do: {:error, :invalid}
  defp validate_frame_start(_), do: :ok

  defp force_skip_to_frame(<<>>), do: <<>>

  defp force_skip_to_frame(payload) do
    payload |> binary_part(1, byte_size(payload) - 1) |> skip_to_frame
  end

  defp skip_to_frame(<<>>), do: <<>>
  defp skip_to_frame(<<0b11111111111::size(11), _::bitstring>> = frame), do: frame

  defp skip_to_frame(payload) do
    # Skip one byte to avoid infinite loop
    next_payload = payload |> binary_part(1, byte_size(payload) - 1)
    size = byte_size(next_payload)

    next_candidate =
      case next_payload |> :binary.match(<<0xFF>>) do
        {pos, _len} ->
          debug("Dropped bytes: #{inspect(binary_part(payload, 0, pos + 1))}")
          next_payload |> binary_part(pos, size - pos)

        :nomatch ->
          <<>>
      end

    next_candidate |> skip_to_frame()
  end
end
