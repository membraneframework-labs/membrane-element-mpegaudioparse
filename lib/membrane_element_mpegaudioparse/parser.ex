defmodule Membrane.Element.MPEGAudioParse.Parser do
  use Membrane.Element.Base.Filter


  def_known_sink_pads %{
    :sink => {:always, :any}
  }


  def_known_source_pads %{
    :source => {:always, [
      %Membrane.Caps.Audio.MPEG{}
    ]}
  }


  # Private API

  @doc false
  def handle_init(_) do
    {:ok, %{}}
  end


  @doc false
  def handle_buffer(:sink, _caps, %Membrane.Buffer{payload: payload} = buffer, state) do
    {:ok, [
      {:caps, {:source, %Membrane.Caps.Audio.MPEG{}}},
      {:send, {:source, buffer}},
    ], state}
  end
end
