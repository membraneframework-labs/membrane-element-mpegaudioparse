defmodule Membrane.Element.MPEGAudioParse.Parser.Helper do
  @moduledoc false

  def parse_version(<<0b00::size(2)>>), do: :v2_5
  def parse_version(<<0b10::size(2)>>), do: :v2
  def parse_version(<<0b11::size(2)>>), do: :v1
  def parse_version(_), do: :invalid

  def parse_layer(<<0b01::size(2)>>), do: :layer3
  def parse_layer(<<0b10::size(2)>>), do: :layer2
  def parse_layer(<<0b11::size(2)>>), do: :layer1
  def parse_layer(_), do: :invalid

  def parse_crc_enabled(<<1::size(1)>>), do: true
  def parse_crc_enabled(<<0::size(1)>>), do: false

  def parse_bitrate(<<0b0000::size(4)>>, _, _), do: :free

  def parse_bitrate(<<0b0001::size(4)>>, :v1, :layer1), do: 32
  def parse_bitrate(<<0b0010::size(4)>>, :v1, :layer1), do: 64
  def parse_bitrate(<<0b0011::size(4)>>, :v1, :layer1), do: 96
  def parse_bitrate(<<0b0100::size(4)>>, :v1, :layer1), do: 128
  def parse_bitrate(<<0b0101::size(4)>>, :v1, :layer1), do: 160
  def parse_bitrate(<<0b0110::size(4)>>, :v1, :layer1), do: 192
  def parse_bitrate(<<0b0111::size(4)>>, :v1, :layer1), do: 224
  def parse_bitrate(<<0b1000::size(4)>>, :v1, :layer1), do: 256
  def parse_bitrate(<<0b1001::size(4)>>, :v1, :layer1), do: 288
  def parse_bitrate(<<0b1010::size(4)>>, :v1, :layer1), do: 320
  def parse_bitrate(<<0b1011::size(4)>>, :v1, :layer1), do: 352
  def parse_bitrate(<<0b1100::size(4)>>, :v1, :layer1), do: 384
  def parse_bitrate(<<0b1101::size(4)>>, :v1, :layer1), do: 416
  def parse_bitrate(<<0b1110::size(4)>>, :v1, :layer1), do: 448

  def parse_bitrate(<<0b0001::size(4)>>, :v1, :layer2), do: 32
  def parse_bitrate(<<0b0010::size(4)>>, :v1, :layer2), do: 48
  def parse_bitrate(<<0b0011::size(4)>>, :v1, :layer2), do: 56
  def parse_bitrate(<<0b0100::size(4)>>, :v1, :layer2), do: 64
  def parse_bitrate(<<0b0101::size(4)>>, :v1, :layer2), do: 80
  def parse_bitrate(<<0b0110::size(4)>>, :v1, :layer2), do: 96
  def parse_bitrate(<<0b0111::size(4)>>, :v1, :layer2), do: 112
  def parse_bitrate(<<0b1000::size(4)>>, :v1, :layer2), do: 128
  def parse_bitrate(<<0b1001::size(4)>>, :v1, :layer2), do: 160
  def parse_bitrate(<<0b1010::size(4)>>, :v1, :layer2), do: 192
  def parse_bitrate(<<0b1011::size(4)>>, :v1, :layer2), do: 224
  def parse_bitrate(<<0b1100::size(4)>>, :v1, :layer2), do: 256
  def parse_bitrate(<<0b1101::size(4)>>, :v1, :layer2), do: 320
  def parse_bitrate(<<0b1110::size(4)>>, :v1, :layer2), do: 384

  def parse_bitrate(<<0b0001::size(4)>>, :v1, :layer3), do: 32
  def parse_bitrate(<<0b0010::size(4)>>, :v1, :layer3), do: 40
  def parse_bitrate(<<0b0011::size(4)>>, :v1, :layer3), do: 48
  def parse_bitrate(<<0b0100::size(4)>>, :v1, :layer3), do: 56
  def parse_bitrate(<<0b0101::size(4)>>, :v1, :layer3), do: 64
  def parse_bitrate(<<0b0110::size(4)>>, :v1, :layer3), do: 80
  def parse_bitrate(<<0b0111::size(4)>>, :v1, :layer3), do: 96
  def parse_bitrate(<<0b1000::size(4)>>, :v1, :layer3), do: 112
  def parse_bitrate(<<0b1001::size(4)>>, :v1, :layer3), do: 128
  def parse_bitrate(<<0b1010::size(4)>>, :v1, :layer3), do: 160
  def parse_bitrate(<<0b1011::size(4)>>, :v1, :layer3), do: 192
  def parse_bitrate(<<0b1100::size(4)>>, :v1, :layer3), do: 224
  def parse_bitrate(<<0b1101::size(4)>>, :v1, :layer3), do: 256
  def parse_bitrate(<<0b1110::size(4)>>, :v1, :layer3), do: 320

  def parse_bitrate(<<0b0001::size(4)>>, :v2, :layer1), do: 32
  def parse_bitrate(<<0b0010::size(4)>>, :v2, :layer1), do: 48
  def parse_bitrate(<<0b0011::size(4)>>, :v2, :layer1), do: 56
  def parse_bitrate(<<0b0100::size(4)>>, :v2, :layer1), do: 64
  def parse_bitrate(<<0b0101::size(4)>>, :v2, :layer1), do: 80
  def parse_bitrate(<<0b0110::size(4)>>, :v2, :layer1), do: 96
  def parse_bitrate(<<0b0111::size(4)>>, :v2, :layer1), do: 112
  def parse_bitrate(<<0b1000::size(4)>>, :v2, :layer1), do: 128
  def parse_bitrate(<<0b1001::size(4)>>, :v2, :layer1), do: 144
  def parse_bitrate(<<0b1010::size(4)>>, :v2, :layer1), do: 160
  def parse_bitrate(<<0b1011::size(4)>>, :v2, :layer1), do: 176
  def parse_bitrate(<<0b1100::size(4)>>, :v2, :layer1), do: 192
  def parse_bitrate(<<0b1101::size(4)>>, :v2, :layer1), do: 224
  def parse_bitrate(<<0b1110::size(4)>>, :v2, :layer1), do: 256

  def parse_bitrate(<<0b0001::size(4)>>, :v2, :layer2), do: 8
  def parse_bitrate(<<0b0010::size(4)>>, :v2, :layer2), do: 16
  def parse_bitrate(<<0b0011::size(4)>>, :v2, :layer2), do: 24
  def parse_bitrate(<<0b0100::size(4)>>, :v2, :layer2), do: 32
  def parse_bitrate(<<0b0101::size(4)>>, :v2, :layer2), do: 40
  def parse_bitrate(<<0b0110::size(4)>>, :v2, :layer2), do: 48
  def parse_bitrate(<<0b0111::size(4)>>, :v2, :layer2), do: 56
  def parse_bitrate(<<0b1000::size(4)>>, :v2, :layer2), do: 64
  def parse_bitrate(<<0b1001::size(4)>>, :v2, :layer2), do: 80
  def parse_bitrate(<<0b1010::size(4)>>, :v2, :layer2), do: 96
  def parse_bitrate(<<0b1011::size(4)>>, :v2, :layer2), do: 112
  def parse_bitrate(<<0b1100::size(4)>>, :v2, :layer2), do: 128
  def parse_bitrate(<<0b1101::size(4)>>, :v2, :layer2), do: 144
  def parse_bitrate(<<0b1110::size(4)>>, :v2, :layer2), do: 160

  def parse_bitrate(<<0b0001::size(4)>>, :v2, :layer3), do: 8
  def parse_bitrate(<<0b0010::size(4)>>, :v2, :layer3), do: 16
  def parse_bitrate(<<0b0011::size(4)>>, :v2, :layer3), do: 24
  def parse_bitrate(<<0b0100::size(4)>>, :v2, :layer3), do: 32
  def parse_bitrate(<<0b0101::size(4)>>, :v2, :layer3), do: 40
  def parse_bitrate(<<0b0110::size(4)>>, :v2, :layer3), do: 48
  def parse_bitrate(<<0b0111::size(4)>>, :v2, :layer3), do: 56
  def parse_bitrate(<<0b1000::size(4)>>, :v2, :layer3), do: 64
  def parse_bitrate(<<0b1001::size(4)>>, :v2, :layer3), do: 80
  def parse_bitrate(<<0b1010::size(4)>>, :v2, :layer3), do: 96
  def parse_bitrate(<<0b1011::size(4)>>, :v2, :layer3), do: 112
  def parse_bitrate(<<0b1100::size(4)>>, :v2, :layer3), do: 128
  def parse_bitrate(<<0b1101::size(4)>>, :v2, :layer3), do: 144
  def parse_bitrate(<<0b1110::size(4)>>, :v2, :layer3), do: 160

  def parse_bitrate(<<0b0001::size(4)>>, :v2_5, :layer1), do: 32
  def parse_bitrate(<<0b0010::size(4)>>, :v2_5, :layer1), do: 48
  def parse_bitrate(<<0b0011::size(4)>>, :v2_5, :layer1), do: 56
  def parse_bitrate(<<0b0100::size(4)>>, :v2_5, :layer1), do: 64
  def parse_bitrate(<<0b0101::size(4)>>, :v2_5, :layer1), do: 80
  def parse_bitrate(<<0b0110::size(4)>>, :v2_5, :layer1), do: 96
  def parse_bitrate(<<0b0111::size(4)>>, :v2_5, :layer1), do: 112
  def parse_bitrate(<<0b1000::size(4)>>, :v2_5, :layer1), do: 128
  def parse_bitrate(<<0b1001::size(4)>>, :v2_5, :layer1), do: 144
  def parse_bitrate(<<0b1010::size(4)>>, :v2_5, :layer1), do: 160
  def parse_bitrate(<<0b1011::size(4)>>, :v2_5, :layer1), do: 176
  def parse_bitrate(<<0b1100::size(4)>>, :v2_5, :layer1), do: 192
  def parse_bitrate(<<0b1101::size(4)>>, :v2_5, :layer1), do: 224
  def parse_bitrate(<<0b1110::size(4)>>, :v2_5, :layer1), do: 256

  def parse_bitrate(<<0b0001::size(4)>>, :v2_5, :layer2), do: 8
  def parse_bitrate(<<0b0010::size(4)>>, :v2_5, :layer2), do: 16
  def parse_bitrate(<<0b0011::size(4)>>, :v2_5, :layer2), do: 24
  def parse_bitrate(<<0b0100::size(4)>>, :v2_5, :layer2), do: 32
  def parse_bitrate(<<0b0101::size(4)>>, :v2_5, :layer2), do: 40
  def parse_bitrate(<<0b0110::size(4)>>, :v2_5, :layer2), do: 48
  def parse_bitrate(<<0b0111::size(4)>>, :v2_5, :layer2), do: 56
  def parse_bitrate(<<0b1000::size(4)>>, :v2_5, :layer2), do: 64
  def parse_bitrate(<<0b1001::size(4)>>, :v2_5, :layer2), do: 80
  def parse_bitrate(<<0b1010::size(4)>>, :v2_5, :layer2), do: 96
  def parse_bitrate(<<0b1011::size(4)>>, :v2_5, :layer2), do: 112
  def parse_bitrate(<<0b1100::size(4)>>, :v2_5, :layer2), do: 128
  def parse_bitrate(<<0b1101::size(4)>>, :v2_5, :layer2), do: 144
  def parse_bitrate(<<0b1110::size(4)>>, :v2_5, :layer2), do: 160

  def parse_bitrate(<<0b0001::size(4)>>, :v2_5, :layer3), do: 8
  def parse_bitrate(<<0b0010::size(4)>>, :v2_5, :layer3), do: 16
  def parse_bitrate(<<0b0011::size(4)>>, :v2_5, :layer3), do: 24
  def parse_bitrate(<<0b0100::size(4)>>, :v2_5, :layer3), do: 32
  def parse_bitrate(<<0b0101::size(4)>>, :v2_5, :layer3), do: 40
  def parse_bitrate(<<0b0110::size(4)>>, :v2_5, :layer3), do: 48
  def parse_bitrate(<<0b0111::size(4)>>, :v2_5, :layer3), do: 56
  def parse_bitrate(<<0b1000::size(4)>>, :v2_5, :layer3), do: 64
  def parse_bitrate(<<0b1001::size(4)>>, :v2_5, :layer3), do: 80
  def parse_bitrate(<<0b1010::size(4)>>, :v2_5, :layer3), do: 96
  def parse_bitrate(<<0b1011::size(4)>>, :v2_5, :layer3), do: 112
  def parse_bitrate(<<0b1100::size(4)>>, :v2_5, :layer3), do: 128
  def parse_bitrate(<<0b1101::size(4)>>, :v2_5, :layer3), do: 144
  def parse_bitrate(<<0b1110::size(4)>>, :v2_5, :layer3), do: 160

  def parse_bitrate(_, _, _), do: :invalid

  def parse_sample_rate(<<0b00::size(2)>>, :v1), do: 44100
  def parse_sample_rate(<<0b01::size(2)>>, :v1), do: 48000
  def parse_sample_rate(<<0b10::size(2)>>, :v1), do: 32000

  def parse_sample_rate(<<0b00::size(2)>>, :v2), do: 22050
  def parse_sample_rate(<<0b01::size(2)>>, :v2), do: 24000
  def parse_sample_rate(<<0b10::size(2)>>, :v2), do: 16000

  def parse_sample_rate(<<0b00::size(2)>>, :v2_5), do: 11050
  def parse_sample_rate(<<0b01::size(2)>>, :v2_5), do: 12000
  def parse_sample_rate(<<0b10::size(2)>>, :v2_5), do: 8000
  def parse_sample_rate(_, _), do: :invalid

  def parse_padding_enabled(<<1::size(1)>>), do: true
  def parse_padding_enabled(<<0::size(1)>>), do: false

  def parse_private(<<1::size(1)>>), do: true
  def parse_private(<<0::size(1)>>), do: false

  def parse_channel_mode(<<0b00::size(2)>>), do: :stereo
  def parse_channel_mode(<<0b01::size(2)>>), do: :joint_stereo
  def parse_channel_mode(<<0b10::size(2)>>), do: :dual_channel
  def parse_channel_mode(<<0b11::size(2)>>), do: :single_channel
  def parse_channel_mode(_), do: :invalid

  def parse_channel_count(:stereo), do: 2
  def parse_channel_count(:joint_stereo), do: 2
  def parse_channel_count(:dual_channel), do: 2
  def parse_channel_count(:single_channel), do: 1

  def parse_mode_extension(_, :stereo), do: nil
  def parse_mode_extension(_, :dual_channel), do: nil
  def parse_mode_extension(_, :single_channel), do: nil

  def parse_mode_extension(<<0b00::size(2)>>, :joint_stereo), do: :mode0
  def parse_mode_extension(<<0b01::size(2)>>, :joint_stereo), do: :mode1
  def parse_mode_extension(<<0b10::size(2)>>, :joint_stereo), do: :mode2
  def parse_mode_extension(<<0b11::size(2)>>, :joint_stereo), do: :mode3
  def parse_mode_extension(_, _), do: :invalid

  def parse_original(<<1::size(1)>>), do: true
  def parse_original(<<0::size(1)>>), do: false

  def parse_copyright(<<1::size(1)>>), do: true
  def parse_copyright(<<0::size(1)>>), do: false

  def parse_emphasis_mode(<<0b00::size(2)>>), do: :none
  def parse_emphasis_mode(<<0b01::size(2)>>), do: :emphasis_50_15
  def parse_emphasis_mode(<<0b11::size(2)>>), do: :ccit_j_17
  def parse_emphasis_mode(_), do: :invalid
end
