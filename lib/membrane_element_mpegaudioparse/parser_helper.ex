defmodule Membrane.Element.MPEGAudioParse.Parser.Helper do
  @moduledoc false
  alias Membrane.Caps.Audio.MPEG

  @spec parse_header(binary) :: {:ok, MPEG.t()} | {:error, :invalid | :unsupported}
  def parse_header(header) do
    with <<0b11111111111::size(11), version::bitstring-size(2), layer::bitstring-size(2),
           crc_enabled::bitstring-size(1), bitrate::bitstring-size(4),
           sample_rate::bitstring-size(2), padding_enabled::bitstring-size(1),
           private::bitstring-size(1), channel_mode::bitstring-size(2),
           mode_extension::bitstring-size(2), copyright::bitstring-size(1),
           original::bitstring-size(1), emphasis_mode::bitstring-size(2), _::binary>> <- header,
         {:ok, version} <- parse_version(version),
         {:ok, layer} <- parse_layer(layer),
         {:ok, channel_mode} <- parse_channel_mode(channel_mode),
         {:ok, channels} <- parse_channel_count(channel_mode),
         {:ok, crc_enabled} <- parse_crc_enabled(crc_enabled),
         {:ok, bitrate} when bitrate != :free <- parse_bitrate(bitrate, version, layer),
         {:ok, sample_rate} <- parse_sample_rate(sample_rate, version),
         {:ok, padding_enabled} <- parse_padding_enabled(padding_enabled),
         {:ok, private} <- parse_private(private),
         {:ok, mode_extension} <- parse_mode_extension(mode_extension, channel_mode),
         {:ok, copyright} <- parse_copyright(copyright),
         {:ok, original} <- parse_original(original),
         {:ok, emphasis_mode} <- parse_emphasis_mode(emphasis_mode) do
      {:ok,
       %MPEG{
         version: version,
         layer: layer,
         crc_enabled: crc_enabled,
         bitrate: bitrate,
         sample_rate: sample_rate,
         padding_enabled: padding_enabled,
         private: private,
         channel_mode: channel_mode,
         channels: channels,
         mode_extension: mode_extension,
         copyright: copyright,
         original: original,
         emphasis_mode: emphasis_mode
       }}
    else
      data when is_binary(data) -> {:error, :invalid}
      {:ok, :free} -> {:error, :unsupported}
      err -> err
    end
  end

  defp parse_version(<<0b00::size(2)>>), do: {:ok, :v2_5}
  defp parse_version(<<0b10::size(2)>>), do: {:ok, :v2}
  defp parse_version(<<0b11::size(2)>>), do: {:ok, :v1}
  defp parse_version(_), do: {:error, :invalid}

  defp parse_layer(<<0b01::size(2)>>), do: {:ok, :layer3}
  defp parse_layer(<<0b10::size(2)>>), do: {:ok, :layer2}
  defp parse_layer(<<0b11::size(2)>>), do: {:ok, :layer1}
  defp parse_layer(_), do: {:error, :invalid}

  defp parse_crc_enabled(<<1::size(1)>>), do: {:ok, true}
  defp parse_crc_enabled(<<0::size(1)>>), do: {:ok, false}

  defp parse_bitrate(<<0b0000::size(4)>>, _, _), do: {:ok, :free}

  defp parse_bitrate(<<0b0001::size(4)>>, :v1, :layer1), do: {:ok, 32}
  defp parse_bitrate(<<0b0010::size(4)>>, :v1, :layer1), do: {:ok, 64}
  defp parse_bitrate(<<0b0011::size(4)>>, :v1, :layer1), do: {:ok, 96}
  defp parse_bitrate(<<0b0100::size(4)>>, :v1, :layer1), do: {:ok, 128}
  defp parse_bitrate(<<0b0101::size(4)>>, :v1, :layer1), do: {:ok, 160}
  defp parse_bitrate(<<0b0110::size(4)>>, :v1, :layer1), do: {:ok, 192}
  defp parse_bitrate(<<0b0111::size(4)>>, :v1, :layer1), do: {:ok, 224}
  defp parse_bitrate(<<0b1000::size(4)>>, :v1, :layer1), do: {:ok, 256}
  defp parse_bitrate(<<0b1001::size(4)>>, :v1, :layer1), do: {:ok, 288}
  defp parse_bitrate(<<0b1010::size(4)>>, :v1, :layer1), do: {:ok, 320}
  defp parse_bitrate(<<0b1011::size(4)>>, :v1, :layer1), do: {:ok, 352}
  defp parse_bitrate(<<0b1100::size(4)>>, :v1, :layer1), do: {:ok, 384}
  defp parse_bitrate(<<0b1101::size(4)>>, :v1, :layer1), do: {:ok, 416}
  defp parse_bitrate(<<0b1110::size(4)>>, :v1, :layer1), do: {:ok, 448}

  defp parse_bitrate(<<0b0001::size(4)>>, :v1, :layer2), do: {:ok, 32}
  defp parse_bitrate(<<0b0010::size(4)>>, :v1, :layer2), do: {:ok, 48}
  defp parse_bitrate(<<0b0011::size(4)>>, :v1, :layer2), do: {:ok, 56}
  defp parse_bitrate(<<0b0100::size(4)>>, :v1, :layer2), do: {:ok, 64}
  defp parse_bitrate(<<0b0101::size(4)>>, :v1, :layer2), do: {:ok, 80}
  defp parse_bitrate(<<0b0110::size(4)>>, :v1, :layer2), do: {:ok, 96}
  defp parse_bitrate(<<0b0111::size(4)>>, :v1, :layer2), do: {:ok, 112}
  defp parse_bitrate(<<0b1000::size(4)>>, :v1, :layer2), do: {:ok, 128}
  defp parse_bitrate(<<0b1001::size(4)>>, :v1, :layer2), do: {:ok, 160}
  defp parse_bitrate(<<0b1010::size(4)>>, :v1, :layer2), do: {:ok, 192}
  defp parse_bitrate(<<0b1011::size(4)>>, :v1, :layer2), do: {:ok, 224}
  defp parse_bitrate(<<0b1100::size(4)>>, :v1, :layer2), do: {:ok, 256}
  defp parse_bitrate(<<0b1101::size(4)>>, :v1, :layer2), do: {:ok, 320}
  defp parse_bitrate(<<0b1110::size(4)>>, :v1, :layer2), do: {:ok, 384}

  defp parse_bitrate(<<0b0001::size(4)>>, :v1, :layer3), do: {:ok, 32}
  defp parse_bitrate(<<0b0010::size(4)>>, :v1, :layer3), do: {:ok, 40}
  defp parse_bitrate(<<0b0011::size(4)>>, :v1, :layer3), do: {:ok, 48}
  defp parse_bitrate(<<0b0100::size(4)>>, :v1, :layer3), do: {:ok, 56}
  defp parse_bitrate(<<0b0101::size(4)>>, :v1, :layer3), do: {:ok, 64}
  defp parse_bitrate(<<0b0110::size(4)>>, :v1, :layer3), do: {:ok, 80}
  defp parse_bitrate(<<0b0111::size(4)>>, :v1, :layer3), do: {:ok, 96}
  defp parse_bitrate(<<0b1000::size(4)>>, :v1, :layer3), do: {:ok, 112}
  defp parse_bitrate(<<0b1001::size(4)>>, :v1, :layer3), do: {:ok, 128}
  defp parse_bitrate(<<0b1010::size(4)>>, :v1, :layer3), do: {:ok, 160}
  defp parse_bitrate(<<0b1011::size(4)>>, :v1, :layer3), do: {:ok, 192}
  defp parse_bitrate(<<0b1100::size(4)>>, :v1, :layer3), do: {:ok, 224}
  defp parse_bitrate(<<0b1101::size(4)>>, :v1, :layer3), do: {:ok, 256}
  defp parse_bitrate(<<0b1110::size(4)>>, :v1, :layer3), do: {:ok, 320}

  defp parse_bitrate(<<0b0001::size(4)>>, :v2, :layer1), do: {:ok, 32}
  defp parse_bitrate(<<0b0010::size(4)>>, :v2, :layer1), do: {:ok, 48}
  defp parse_bitrate(<<0b0011::size(4)>>, :v2, :layer1), do: {:ok, 56}
  defp parse_bitrate(<<0b0100::size(4)>>, :v2, :layer1), do: {:ok, 64}
  defp parse_bitrate(<<0b0101::size(4)>>, :v2, :layer1), do: {:ok, 80}
  defp parse_bitrate(<<0b0110::size(4)>>, :v2, :layer1), do: {:ok, 96}
  defp parse_bitrate(<<0b0111::size(4)>>, :v2, :layer1), do: {:ok, 112}
  defp parse_bitrate(<<0b1000::size(4)>>, :v2, :layer1), do: {:ok, 128}
  defp parse_bitrate(<<0b1001::size(4)>>, :v2, :layer1), do: {:ok, 144}
  defp parse_bitrate(<<0b1010::size(4)>>, :v2, :layer1), do: {:ok, 160}
  defp parse_bitrate(<<0b1011::size(4)>>, :v2, :layer1), do: {:ok, 176}
  defp parse_bitrate(<<0b1100::size(4)>>, :v2, :layer1), do: {:ok, 192}
  defp parse_bitrate(<<0b1101::size(4)>>, :v2, :layer1), do: {:ok, 224}
  defp parse_bitrate(<<0b1110::size(4)>>, :v2, :layer1), do: {:ok, 256}

  defp parse_bitrate(<<0b0001::size(4)>>, :v2, :layer2), do: {:ok, 8}
  defp parse_bitrate(<<0b0010::size(4)>>, :v2, :layer2), do: {:ok, 16}
  defp parse_bitrate(<<0b0011::size(4)>>, :v2, :layer2), do: {:ok, 24}
  defp parse_bitrate(<<0b0100::size(4)>>, :v2, :layer2), do: {:ok, 32}
  defp parse_bitrate(<<0b0101::size(4)>>, :v2, :layer2), do: {:ok, 40}
  defp parse_bitrate(<<0b0110::size(4)>>, :v2, :layer2), do: {:ok, 48}
  defp parse_bitrate(<<0b0111::size(4)>>, :v2, :layer2), do: {:ok, 56}
  defp parse_bitrate(<<0b1000::size(4)>>, :v2, :layer2), do: {:ok, 64}
  defp parse_bitrate(<<0b1001::size(4)>>, :v2, :layer2), do: {:ok, 80}
  defp parse_bitrate(<<0b1010::size(4)>>, :v2, :layer2), do: {:ok, 96}
  defp parse_bitrate(<<0b1011::size(4)>>, :v2, :layer2), do: {:ok, 112}
  defp parse_bitrate(<<0b1100::size(4)>>, :v2, :layer2), do: {:ok, 128}
  defp parse_bitrate(<<0b1101::size(4)>>, :v2, :layer2), do: {:ok, 144}
  defp parse_bitrate(<<0b1110::size(4)>>, :v2, :layer2), do: {:ok, 160}

  defp parse_bitrate(<<0b0001::size(4)>>, :v2, :layer3), do: {:ok, 8}
  defp parse_bitrate(<<0b0010::size(4)>>, :v2, :layer3), do: {:ok, 16}
  defp parse_bitrate(<<0b0011::size(4)>>, :v2, :layer3), do: {:ok, 24}
  defp parse_bitrate(<<0b0100::size(4)>>, :v2, :layer3), do: {:ok, 32}
  defp parse_bitrate(<<0b0101::size(4)>>, :v2, :layer3), do: {:ok, 40}
  defp parse_bitrate(<<0b0110::size(4)>>, :v2, :layer3), do: {:ok, 48}
  defp parse_bitrate(<<0b0111::size(4)>>, :v2, :layer3), do: {:ok, 56}
  defp parse_bitrate(<<0b1000::size(4)>>, :v2, :layer3), do: {:ok, 64}
  defp parse_bitrate(<<0b1001::size(4)>>, :v2, :layer3), do: {:ok, 80}
  defp parse_bitrate(<<0b1010::size(4)>>, :v2, :layer3), do: {:ok, 96}
  defp parse_bitrate(<<0b1011::size(4)>>, :v2, :layer3), do: {:ok, 112}
  defp parse_bitrate(<<0b1100::size(4)>>, :v2, :layer3), do: {:ok, 128}
  defp parse_bitrate(<<0b1101::size(4)>>, :v2, :layer3), do: {:ok, 144}
  defp parse_bitrate(<<0b1110::size(4)>>, :v2, :layer3), do: {:ok, 160}

  defp parse_bitrate(<<0b0001::size(4)>>, :v2_5, :layer1), do: {:ok, 32}
  defp parse_bitrate(<<0b0010::size(4)>>, :v2_5, :layer1), do: {:ok, 48}
  defp parse_bitrate(<<0b0011::size(4)>>, :v2_5, :layer1), do: {:ok, 56}
  defp parse_bitrate(<<0b0100::size(4)>>, :v2_5, :layer1), do: {:ok, 64}
  defp parse_bitrate(<<0b0101::size(4)>>, :v2_5, :layer1), do: {:ok, 80}
  defp parse_bitrate(<<0b0110::size(4)>>, :v2_5, :layer1), do: {:ok, 96}
  defp parse_bitrate(<<0b0111::size(4)>>, :v2_5, :layer1), do: {:ok, 112}
  defp parse_bitrate(<<0b1000::size(4)>>, :v2_5, :layer1), do: {:ok, 128}
  defp parse_bitrate(<<0b1001::size(4)>>, :v2_5, :layer1), do: {:ok, 144}
  defp parse_bitrate(<<0b1010::size(4)>>, :v2_5, :layer1), do: {:ok, 160}
  defp parse_bitrate(<<0b1011::size(4)>>, :v2_5, :layer1), do: {:ok, 176}
  defp parse_bitrate(<<0b1100::size(4)>>, :v2_5, :layer1), do: {:ok, 192}
  defp parse_bitrate(<<0b1101::size(4)>>, :v2_5, :layer1), do: {:ok, 224}
  defp parse_bitrate(<<0b1110::size(4)>>, :v2_5, :layer1), do: {:ok, 256}

  defp parse_bitrate(<<0b0001::size(4)>>, :v2_5, :layer2), do: {:ok, 8}
  defp parse_bitrate(<<0b0010::size(4)>>, :v2_5, :layer2), do: {:ok, 16}
  defp parse_bitrate(<<0b0011::size(4)>>, :v2_5, :layer2), do: {:ok, 24}
  defp parse_bitrate(<<0b0100::size(4)>>, :v2_5, :layer2), do: {:ok, 32}
  defp parse_bitrate(<<0b0101::size(4)>>, :v2_5, :layer2), do: {:ok, 40}
  defp parse_bitrate(<<0b0110::size(4)>>, :v2_5, :layer2), do: {:ok, 48}
  defp parse_bitrate(<<0b0111::size(4)>>, :v2_5, :layer2), do: {:ok, 56}
  defp parse_bitrate(<<0b1000::size(4)>>, :v2_5, :layer2), do: {:ok, 64}
  defp parse_bitrate(<<0b1001::size(4)>>, :v2_5, :layer2), do: {:ok, 80}
  defp parse_bitrate(<<0b1010::size(4)>>, :v2_5, :layer2), do: {:ok, 96}
  defp parse_bitrate(<<0b1011::size(4)>>, :v2_5, :layer2), do: {:ok, 112}
  defp parse_bitrate(<<0b1100::size(4)>>, :v2_5, :layer2), do: {:ok, 128}
  defp parse_bitrate(<<0b1101::size(4)>>, :v2_5, :layer2), do: {:ok, 144}
  defp parse_bitrate(<<0b1110::size(4)>>, :v2_5, :layer2), do: {:ok, 160}

  defp parse_bitrate(<<0b0001::size(4)>>, :v2_5, :layer3), do: {:ok, 8}
  defp parse_bitrate(<<0b0010::size(4)>>, :v2_5, :layer3), do: {:ok, 16}
  defp parse_bitrate(<<0b0011::size(4)>>, :v2_5, :layer3), do: {:ok, 24}
  defp parse_bitrate(<<0b0100::size(4)>>, :v2_5, :layer3), do: {:ok, 32}
  defp parse_bitrate(<<0b0101::size(4)>>, :v2_5, :layer3), do: {:ok, 40}
  defp parse_bitrate(<<0b0110::size(4)>>, :v2_5, :layer3), do: {:ok, 48}
  defp parse_bitrate(<<0b0111::size(4)>>, :v2_5, :layer3), do: {:ok, 56}
  defp parse_bitrate(<<0b1000::size(4)>>, :v2_5, :layer3), do: {:ok, 64}
  defp parse_bitrate(<<0b1001::size(4)>>, :v2_5, :layer3), do: {:ok, 80}
  defp parse_bitrate(<<0b1010::size(4)>>, :v2_5, :layer3), do: {:ok, 96}
  defp parse_bitrate(<<0b1011::size(4)>>, :v2_5, :layer3), do: {:ok, 112}
  defp parse_bitrate(<<0b1100::size(4)>>, :v2_5, :layer3), do: {:ok, 128}
  defp parse_bitrate(<<0b1101::size(4)>>, :v2_5, :layer3), do: {:ok, 144}
  defp parse_bitrate(<<0b1110::size(4)>>, :v2_5, :layer3), do: {:ok, 160}

  defp parse_bitrate(_, _, _), do: {:error, :invalid}

  defp parse_sample_rate(<<0b00::size(2)>>, :v1), do: {:ok, 44_100}
  defp parse_sample_rate(<<0b01::size(2)>>, :v1), do: {:ok, 48_000}
  defp parse_sample_rate(<<0b10::size(2)>>, :v1), do: {:ok, 32_000}

  defp parse_sample_rate(<<0b00::size(2)>>, :v2), do: {:ok, 22_050}
  defp parse_sample_rate(<<0b01::size(2)>>, :v2), do: {:ok, 24_000}
  defp parse_sample_rate(<<0b10::size(2)>>, :v2), do: {:ok, 16_000}

  defp parse_sample_rate(<<0b00::size(2)>>, :v2_5), do: {:ok, 11_050}
  defp parse_sample_rate(<<0b01::size(2)>>, :v2_5), do: {:ok, 12_000}
  defp parse_sample_rate(<<0b10::size(2)>>, :v2_5), do: {:ok, 8000}
  defp parse_sample_rate(_, _), do: {:error, :invalid}

  defp parse_padding_enabled(<<1::size(1)>>), do: {:ok, true}
  defp parse_padding_enabled(<<0::size(1)>>), do: {:ok, false}
  defp parse_padding_enabled(_), do: {:error, :invalid}

  defp parse_private(<<1::size(1)>>), do: {:ok, true}
  defp parse_private(<<0::size(1)>>), do: {:ok, false}
  defp parse_private(_), do: {:error, :invalid}

  defp parse_channel_mode(<<0b00::size(2)>>), do: {:ok, :stereo}
  defp parse_channel_mode(<<0b01::size(2)>>), do: {:ok, :joint_stereo}
  defp parse_channel_mode(<<0b10::size(2)>>), do: {:ok, :dual_channel}
  defp parse_channel_mode(<<0b11::size(2)>>), do: {:ok, :single_channel}
  defp parse_channel_mode(_), do: {:error, :invalid}

  defp parse_channel_count(:stereo), do: {:ok, 2}
  defp parse_channel_count(:joint_stereo), do: {:ok, 2}
  defp parse_channel_count(:dual_channel), do: {:ok, 2}
  defp parse_channel_count(:single_channel), do: {:ok, 1}
  defp parse_channel_count(_), do: {:error, :invalid}

  defp parse_mode_extension(_, :stereo), do: {:ok, nil}
  defp parse_mode_extension(_, :dual_channel), do: {:ok, nil}
  defp parse_mode_extension(_, :single_channel), do: {:ok, nil}
  defp parse_mode_extension(<<0b00::size(2)>>, :joint_stereo), do: {:ok, :mode0}
  defp parse_mode_extension(<<0b01::size(2)>>, :joint_stereo), do: {:ok, :mode1}
  defp parse_mode_extension(<<0b10::size(2)>>, :joint_stereo), do: {:ok, :mode2}
  defp parse_mode_extension(<<0b11::size(2)>>, :joint_stereo), do: {:ok, :mode3}
  defp parse_mode_extension(_, _), do: {:error, :invalid}

  defp parse_original(<<1::size(1)>>), do: {:ok, true}
  defp parse_original(<<0::size(1)>>), do: {:ok, false}
  defp parse_original(_), do: {:error, :invalid}

  defp parse_copyright(<<1::size(1)>>), do: {:ok, true}
  defp parse_copyright(<<0::size(1)>>), do: {:ok, false}
  defp parse_copyright(_), do: {:error, :invalid}

  defp parse_emphasis_mode(<<0b00::size(2)>>), do: {:ok, :none}
  defp parse_emphasis_mode(<<0b01::size(2)>>), do: {:ok, :emphasis_50_15}
  defp parse_emphasis_mode(<<0b11::size(2)>>), do: {:ok, :ccit_j_17}
  defp parse_emphasis_mode(_), do: {:error, :invalid}
end
