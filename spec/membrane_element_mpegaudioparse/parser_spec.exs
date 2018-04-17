defmodule Membrane.Element.MPEGAudioParse.ParserSpec do
  use ESpec, async: true
  require Membrane

  @caps_no_padding %Membrane.Caps.Audio.MPEG{
    bitrate: 96,
    channel_mode: :single_channel,
    channels: 1,
    copyright: false,
    crc_enabled: true,
    emphasis_mode: :none,
    layer: :layer3,
    mode_extension: nil,
    original: true,
    padding_enabled: false,
    private: false,
    sample_rate: 44100,
    version: :v1
  }

  @caps_with_padding %Membrane.Caps.Audio.MPEG{
    bitrate: 96,
    channel_mode: :single_channel,
    channels: 1,
    copyright: false,
    crc_enabled: true,
    emphasis_mode: :none,
    layer: :layer3,
    mode_extension: nil,
    original: true,
    padding_enabled: true,
    private: false,
    sample_rate: 44100,
    version: :v1
  }

  @fixture_path "#{__DIR__}/../fixtures/mpeg-audio-cbr-joint-100ms.mp3"

  @fixture_commands [
    caps: {:source, @caps_no_padding},
    buffer:
      {:source,
       %Membrane.Buffer{
         metadata: %{},
         payload:
           <<255, 251, 112, 196, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 73, 110, 102,
             111, 0, 0, 0, 15, 0, 0, 0, 5, 0, 0, 7, 88, 0, 51, 51, 51, 51, 51, 51, 51, 51, 51, 51,
             51, 51, 51, 51, 51, 51, 51, 51, 51, 102, 102, 102, 102, 102, 102, 102, 102, 102, 102,
             102, 102, 102, 102, 102, 102, 102, 102, 102, 102, 153, 153, 153, 153, 153, 153, 153,
             153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 153, 204, 204, 204, 204,
             204, 204, 204, 204, 204, 204, 204, 204, 204, 204, 204, 204, 204, 204, 204, 204, 255,
             255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
             255, 255, 0, 0, 0, 57, 76, 65, 77, 69, 51, 46, 57, 57, 114, 1, 205, 0, 0, 0, 0, 0, 0,
             0, 0, 20, 96, 36, 3, 6, 66, 0, 0, 96, 0, 0, 7, 88, 114, 106, 105, 185, 0, 0, 0, 0, 0,
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
       }},
    buffer:
      {:source,
       %Membrane.Buffer{
         metadata: %{},
         payload:
           <<255, 251, 112, 196, 0, 0, 8, 252, 33, 88, 244, 241, 128, 35, 9, 184, 38, 27, 61, 64,
             0, 0, 37, 223, 108, 183, 9, 184, 155, 144, 181, 179, 112, 47, 0, 116, 5, 64, 224, 66,
             216, 213, 234, 245, 123, 247, 224, 248, 32, 8, 2, 7, 48, 124, 63, 130, 0, 134, 176,
             124, 254, 80, 49, 41, 239, 232, 247, 244, 123, 250, 10, 84, 8, 3, 231, 226, 112, 112,
             16, 195, 0, 249, 249, 112, 32, 33, 144, 7, 223, 148, 57, 223, 208, 1, 0, 0, 2, 8, 65,
             1, 137, 105, 24, 24, 167, 223, 193, 129, 48, 54, 24, 212, 204, 1, 130, 96, 6, 25, 5,
             156, 49, 176, 225, 55, 152, 42, 132, 161, 194, 0, 160, 18, 129, 89, 208, 16, 101, 18,
             1, 201, 134, 232, 65, 24, 61, 132, 0, 112, 53, 72, 193, 64, 53, 43, 3, 40, 220, 13,
             162, 211, 39, 192, 214, 53, 0, 18, 64, 100, 200, 34, 182, 224, 100, 75, 0, 176, 48,
             48, 128, 192, 194, 9, 82, 191, 11, 228, 13, 178, 6, 195, 7, 234, 23, 11, 255, 133,
             160, 138, 72, 53, 112, 100, 97, 141, 16, 87, 255, 195, 0, 138, 72, 65, 96, 248, 134,
             52, 80, 34, 21, 255, 252, 114, 133, 204, 43, 98, 26, 46, 81, 114, 144, 225, 206, 28,
             239, 255, 252, 134, 139, 148, 115, 73, 161, 206, 28, 226, 137, 21, 34, 166, 68, 91,
             255, 255, 242, 120, 196, 186, 93, 56, 94, 54, 89, 117, 148, 146, 116, 127, 255, 255,
             255, 85, 215, 164, 141, 21, 41, 37, 162, 98, 146, 70, 95, 233, 233, 255, 250, 149,
             48, 31, 128, 211, 48, 33, 128, 211, 48, 119, 130, 43, 48, 23, 1, 228, 48, 60, 194,
             152, 55, 211, 124, 43, 54>>
       }},
    caps: {:source, @caps_with_padding},
    buffer:
      {:source,
       %Membrane.Buffer{
         metadata: %{},
         payload:
           <<255, 251, 114, 196, 12, 131, 207, 6, 7, 22, 29, 242, 128, 9, 252, 193, 98, 129, 254,
             148, 217, 40, 142, 149, 49, 230, 132, 231, 48, 236, 130, 169, 48, 112, 66, 54, 48,
             127, 193, 244, 48, 138, 193, 170, 48, 46, 192, 168, 73, 38, 46, 152, 50, 25, 161,
             198, 55, 253, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
             255, 255, 255, 255, 191, 183, 213, 127, 251, 214, 174, 168, 48, 202, 164, 69, 209,
             98, 2, 123, 15, 153, 136, 102, 99, 161, 170, 194, 199, 65, 119, 139, 137, 16, 105,
             106, 97, 104, 56, 76, 104, 210, 9, 135, 24, 5, 160, 25, 152, 19, 128, 84, 24, 37, 32,
             166, 152, 69, 65, 83, 24, 159, 228, 12, 156, 15, 94, 241, 155, 246, 228, 15, 152,
             162, 193, 118, 28, 202, 251, 154, 154, 184, 154, 96, 165, 26, 95, 24, 153, 126, 87,
             152, 80, 7, 32, 13, 156, 63, 241, 128, 224, 187, 107, 255, 255, 255, 255, 215, 255,
             255, 255, 255, 167, 255, 253, 125, 58, 219, 255, 237, 255, 255, 255, 255, 255, 107,
             105, 246, 68, 125, 203, 54, 86, 123, 189, 144, 206, 120, 247, 17, 32, 242, 226, 101,
             20, 86, 34, 139, 33, 92, 69, 130, 34, 74, 31, 41, 69, 132, 10, 87, 21, 5, 23, 8, 163,
             145, 5, 148, 80, 52, 165, 85, 48, 34, 64, 150, 48, 37, 128, 203, 48, 51, 65, 60, 48,
             86, 2, 101, 48, 198, 71, 92, 53, 43, 185, 36, 53, 9, 71, 50, 48, 181, 130, 17, 53,
             186, 40, 201, 198, 19, 102, 171, 14, 13, 89, 53, 129, 156, 4, 70, 77, 87, 90, 91,
             125, 77, 255, 183, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 127, 255,
             255>>
       }},
    caps: {:source, @caps_no_padding},
    buffer:
      {:source,
       %Membrane.Buffer{
         metadata: %{},
         payload:
           <<255, 251, 112, 196, 35, 3, 205, 150, 13, 24, 15, 240, 70, 193, 233, 65, 162, 129,
             254, 148, 216, 255, 255, 255, 254, 223, 244, 253, 149, 249, 209, 105, 244, 220, 207,
             118, 89, 230, 86, 66, 163, 57, 44, 198, 174, 21, 218, 143, 83, 17, 85, 33, 4, 136, 2,
             99, 8, 69, 3, 57, 128, 104, 1, 65, 129, 70, 4, 249, 130, 96, 9, 241, 132, 114, 20,
             105, 138, 52, 62, 97, 194, 107, 220, 193, 192, 216, 62, 161, 138, 98, 22, 201, 205,
             79, 129, 169, 75, 161, 164, 234, 153, 164, 81, 241, 150, 197, 145, 132, 160, 122, 14,
             51, 183, 242, 54, 31, 20, 125, 63, 255, 255, 255, 250, 127, 255, 255, 255, 255, 255,
             255, 255, 255, 254, 255, 255, 255, 255, 253, 214, 221, 254, 153, 233, 162, 22, 86,
             117, 24, 82, 22, 99, 29, 103, 58, 152, 80, 200, 150, 99, 187, 139, 236, 53, 220, 52,
             166, 34, 35, 141, 22, 17, 59, 49, 93, 88, 58, 163, 130, 143, 153, 132, 206, 48, 33,
             128, 153, 48, 36, 192, 204, 48, 49, 1, 69, 48, 82, 194, 114, 48, 189, 135, 135, 52,
             248, 250, 95, 52, 214, 135, 95, 48, 173, 194, 32, 48, 40, 128, 155, 48, 22, 64, 84,
             48, 53, 0, 163, 48, 67, 65, 74, 48, 45, 64, 96, 1, 0, 146, 154, 206, 172, 186, 246,
             177, 255, 255, 255, 255, 255, 239, 255, 255, 255, 255, 214, 155, 239, 211, 215, 60,
             154, 17, 223, 73, 37, 25, 217, 149, 67, 157, 89, 29, 129, 3, 59, 148, 230, 113, 66,
             24, 179, 202, 162, 136, 33, 203, 32, 232, 162, 206, 96, 23, 0, 138, 96, 69, 130, 94,
             97, 30, 131, 222, 96, 249, 9, 72, 98, 113, 19, 20, 119, 176, 123, 150>>
       }},
    caps: {:source, @caps_with_padding},
    buffer:
      {:source,
       %Membrane.Buffer{
         metadata: %{},
         payload:
           <<255, 251, 114, 196, 65, 131, 205, 94, 13, 24, 15, 128, 87, 194, 77, 193, 98, 66, 190,
             112, 1, 116, 171, 168, 190, 101, 132, 143, 118, 98, 241, 133, 166, 96, 237, 135, 42,
             97, 156, 133, 206, 97, 141, 133, 202, 96, 95, 130, 26, 96, 26, 128, 22, 24, 0, 186,
             38, 53, 199, 80, 32, 26, 16, 215, 255, 255, 255, 255, 175, 255, 255, 255, 254, 180,
             255, 219, 219, 162, 255, 85, 190, 110, 252, 223, 253, 127, 255, 255, 171, 123, 187,
             217, 211, 159, 162, 147, 61, 14, 86, 152, 121, 167, 24, 166, 180, 104, 197, 206, 48,
             152, 241, 104, 249, 199, 185, 170, 104, 209, 7, 203, 42, 178, 18, 30, 156, 65, 136,
             57, 164, 216, 242, 110, 62, 48, 80, 124, 187, 158, 112, 144, 163, 97, 226, 2, 42, 0,
             0, 0, 33, 8, 0, 128, 8, 0, 236, 96, 1, 1, 0, 64, 0, 192, 132, 9, 140, 59, 142, 192,
             195, 144, 78, 140, 73, 23, 32, 193, 168, 34, 204, 18, 196, 104, 211, 28, 4, 8, 0, 56,
             207, 92, 14, 204, 63, 2, 224, 197, 188, 97, 12, 4, 128, 156, 32, 14, 233, 140, 27, 1,
             136, 193, 16, 5, 4, 128, 69, 27, 67, 11, 136, 72, 6, 196, 232, 24, 241, 36, 248, 96,
             17, 216, 50, 4, 12, 6, 3, 128, 49, 0, 196, 129, 115, 162, 122, 11, 134, 43, 149, 203,
             140, 41, 65, 0, 205, 211, 11, 66, 20, 136, 106, 208, 200, 172, 159, 32, 162, 23, 25,
             48, 248, 3, 20, 12, 112, 160, 132, 44, 67, 71, 55, 218, 68, 6, 108, 115, 200, 152,
             204, 16, 65, 205, 50, 54, 50, 165, 252, 136, 12, 217, 23, 39, 200, 129, 162, 9, 44,
             186, 93, 50, 47, 17, 111, 249, 186, 12>>
       }},
    caps: {:source, @caps_no_padding},
    buffer:
      {:source,
       %Membrane.Buffer{
         metadata: %{},
         payload:
           <<255, 251, 112, 196, 84, 128, 29, 161, 125, 59, 249, 234, 0, 1, 59, 134, 163, 31, 176,
             96, 0, 102, 95, 55, 34, 132, 80, 168, 98, 93, 38, 76, 139, 197, 228, 81, 71, 255,
             147, 229, 243, 114, 112, 184, 104, 95, 77, 52, 62, 146, 75, 69, 21, 37, 255, 255, 65,
             147, 77, 208, 65, 4, 211, 116, 16, 50, 18, 132, 129, 174, 91, 255, 240, 31, 12, 3,
             224, 64, 192, 62, 127, 194, 160, 168, 136, 42, 10, 245, 157, 0, 72, 18, 164, 155, 36,
             113, 140, 198, 113, 36, 147, 49, 69, 86, 130, 141, 198, 16, 47, 85, 164, 145, 76, 26,
             157, 217, 107, 176, 237, 227, 65, 64, 32, 20, 88, 149, 60, 26, 14, 193, 163, 185, 80,
             216, 148, 52, 160, 105, 64, 211, 202, 157, 42, 26, 135, 97, 222, 87, 242, 199, 184,
             43, 5, 101, 143, 22, 124, 151, 255, 219, 193, 168, 138, 179, 171, 193, 168, 53, 76,
             65, 77, 69, 51, 46, 57, 57, 46, 53, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
             85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
             85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
             85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
             85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
             85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85,
             85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85>>
       }}
  ]

  def expect_total_buffers_size(commands, size) do
    total_size =
      commands
      |> Enum.reject(fn command ->
        case command do
          {:buffer, _} -> false
          _ -> true
        end
      end)
      |> Enum.reduce(0, fn {:buffer, {_, %Membrane.Buffer{payload: payload}}}, acc ->
        acc + byte_size(payload)
      end)

    expect(total_size) |> to(eq size)
  end

  describe ".handle_process1/4" do
    let :buffer, do: %Membrane.Buffer{payload: payload()}
    let :state, do: %{queue: queue(), caps: nil, frame_size: nil, skip_until_frame: false}

    context "if received buffer contains not enough data for the header" do
      context "and queue was empty" do
        let :queue, do: <<>>
        let :payload, do: File.read!(@fixture_path) |> Kernel.binary_part(0, 31)

        it "should return no commands" do
          {{:ok, commands}, _state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(commands) |> to(eq [])
        end

        it "should store read data in the queue" do
          {{:ok, _commands}, new_state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(new_state[:queue]) |> to(eq payload())
        end

        it "should keep caps in the state untouched" do
          {{:ok, _commands}, new_state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(new_state[:caps]) |> to(be_nil())
        end
      end

      context "and queue was not empty" do
        let :queue, do: File.read!(@fixture_path) |> Kernel.binary_part(0, 1)
        let :payload, do: File.read!(@fixture_path) |> Kernel.binary_part(1, 30)

        it "should return no commands" do
          {{:ok, commands}, _state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(commands) |> to(eq [])
        end

        it "should append read data to the queue" do
          {{:ok, _commands}, new_state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(new_state[:queue]) |> to(eq queue() <> payload())
        end

        it "should keep caps in the state untouched" do
          {{:ok, _commands}, new_state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(new_state[:caps]) |> to(be_nil())
        end
      end
    end

    context "if received buffer contains enough data for the header but not enough for the frame payload" do
      context "and queue was empty" do
        let :queue, do: <<>>
        let :payload, do: File.read!(@fixture_path) |> Kernel.binary_part(0, 100)

        it "should return no commands" do
          {{:ok, commands}, _state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(commands) |> to(eq [])
        end

        it "should store read data in the queue" do
          {{:ok, _commands}, new_state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(new_state[:queue]) |> to(eq payload())
        end

        it "should keep caps in the state untouched" do
          {{:ok, _commands}, new_state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(new_state[:caps]) |> to(be_nil())
        end
      end

      context "and queue was not empty" do
        let :queue, do: File.read!(@fixture_path) |> Kernel.binary_part(0, 1)
        let :payload, do: File.read!(@fixture_path) |> Kernel.binary_part(1, 100)

        it "should return no commands" do
          {{:ok, commands}, _state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(commands) |> to(eq [])
        end

        it "should append read data to the queue" do
          {{:ok, _commands}, new_state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(new_state[:queue]) |> to(eq queue() <> payload())
        end

        it "should keep caps in the state untouched" do
          {{:ok, _commands}, new_state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(new_state[:caps]) |> to(be_nil())
        end
      end
    end

    context "if received buffer contains exactly a whole MP3 file with many frames" do
      let :queue, do: <<>>
      let :payload, do: File.read!(@fixture_path)

      it "should return commands with caps before each change plus many buffers, one per each frame in the audio" do
        {{:ok, commands}, _state} =
          described_module().handle_process1(:sink, buffer(), nil, state())

        expect(commands) |> to(eq @fixture_commands)
      end

      it "should return state with empty queue" do
        {{:ok, _commands}, new_state} =
          described_module().handle_process1(:sink, buffer(), nil, state())

        expect(new_state[:queue]) |> to(eq <<>>)
      end

      it "should return commands for which total payload size of buffers is equal to the processed payload" do
        {{:ok, commands}, _state} =
          described_module().handle_process1(:sink, buffer(), nil, state())

        expect_total_buffers_size(commands, byte_size(payload()))
      end

      it "should return state with caps set to the last caps" do
        {{:ok, _commands}, new_state} =
          described_module().handle_process1(:sink, buffer(), nil, state())

        expect(new_state[:caps]) |> to(eq @caps_no_padding)
      end
    end

    context "if received buffer contains invalid data before a whole MP3 file" do
      let :queue, do: <<>>
      let :garbage, do: 1..100 |> Enum.to_list() |> :binary.list_to_bin()
      let :payload, do: garbage() <> File.read!(@fixture_path)

      context "and skip_until_frame option is true" do
        let :state, do: %{queue: queue(), caps: nil, frame_size: nil, skip_until_frame: true}

        it "should return commands with caps before each change plus many buffers, one per each frame in the audio" do
          {{:ok, commands}, _state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(commands) |> to(eq @fixture_commands)
        end

        it "should return state with empty queue" do
          {{:ok, _commands}, new_state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(new_state[:queue]) |> to(eq <<>>)
        end

        it "should return commands for which total payload size of buffers is equal to the valid payload (without garbage)" do
          {{:ok, commands}, _state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect_total_buffers_size(commands, byte_size(payload()) - byte_size(garbage()))
        end

        it "should return state with caps set to the last caps" do
          {{:ok, _commands}, new_state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(new_state[:caps]) |> to(eq @caps_no_padding)
        end
      end

      context "and skip_until_frame option is false" do
        let :state, do: %{queue: queue(), caps: nil, frame_size: nil, skip_until_frame: false}

        it "should raise an exception" do
          lazy_result = fn ->
            described_module().handle_process1(:sink, buffer(), nil, state())
          end

          expect(lazy_result) |> to(raise_exception())
        end
      end
    end

    context "if received buffer contains a whole MP3 file with many frames plus some spare bytes" do
      context "and queue was empty" do
        let :spare, do: File.read!(@fixture_path) |> Kernel.binary_part(0, 3)
        let :payload, do: File.read!(@fixture_path) <> spare()
        let :queue, do: <<>>

        it "should return commands with caps before each change plus many buffers, one per each frame in the audio" do
          {{:ok, commands}, _state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(commands) |> to(eq @fixture_commands)
        end

        it "should return commands for which total payload size of buffers is equal to the processed payload minus size of spare bytes" do
          {{:ok, commands}, _state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect_total_buffers_size(commands, byte_size(payload()) - byte_size(spare()))
        end

        it "should return state with queue set to the spare bytes" do
          {{:ok, _commands}, new_state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(new_state[:queue]) |> to(eq spare())
        end

        it "should return state with caps set to the last caps" do
          {{:ok, _commands}, new_state} =
            described_module().handle_process1(:sink, buffer(), nil, state())

          expect(new_state[:caps]) |> to(eq @caps_no_padding)
        end
      end
    end

    context "given that queue was not empty" do
      let :queue, do: File.read!(@fixture_path) |> Kernel.binary_part(0, 3)
      let :spare, do: File.read!(@fixture_path) |> Kernel.binary_part(0, 3)
      let :fixture_size, do: File.stat!(@fixture_path).size

      let :payload,
        do: (File.read!(@fixture_path) |> Kernel.binary_part(3, fixture_size() - 3)) <> spare()

      it "should return commands with caps before each change plus many buffers, one per each frame in the audio" do
        {{:ok, commands}, _state} =
          described_module().handle_process1(:sink, buffer(), nil, state())

        expect(commands) |> to(eq @fixture_commands)
      end

      it "should return commands for which total payload size of buffers is equal to the processed payload (including queue) minus size of spare bytes" do
        {{:ok, commands}, _state} =
          described_module().handle_process1(:sink, buffer(), nil, state())

        total_size =
          commands
          |> Enum.reject(fn command ->
            case command do
              {:buffer, _} -> false
              _ -> true
            end
          end)
          |> Enum.reduce(0, fn {:buffer, {_, %Membrane.Buffer{payload: payload}}}, acc ->
            acc + byte_size(payload)
          end)

        expect(total_size)
        |> to(eq byte_size(queue()) + byte_size(payload()) - byte_size(spare()))
      end

      it "should return state with queue set to the spare bytes" do
        {{:ok, _commands}, new_state} =
          described_module().handle_process1(:sink, buffer(), nil, state())

        expect(new_state[:queue]) |> to(eq spare())
      end

      it "should return state with caps set to the last caps" do
        {{:ok, _commands}, new_state} =
          described_module().handle_process1(:sink, buffer(), nil, state())

        expect(new_state[:caps]) |> to(eq @caps_no_padding)
      end
    end
  end
end
