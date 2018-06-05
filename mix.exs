defmodule Membrane.Element.MPEGAudioParse.Mixfile do
  use Mix.Project

  def project do
    [
      app: :membrane_element_mpegaudioparse,
      compilers: Mix.compilers(),
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "Membrane Multimedia Framework (MPEGAudioParse Element)",
      package: package(),
      name: "Membrane Element: MPEGAudioParse",
      source_url: link(),
      homepage_url: "https://membraneframework.org",
      preferred_cli_env: [espec: :test, format: :test],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [],
      mod: {Membrane.Element.MPEGAudioParse, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "spec/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp link do
    "https://github.com/membraneframework/membrane-element-mpegaudioparse"
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => link()}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:membrane_core, git: "git@github.com:membraneframework/membrane-core.git"},
      {:membrane_caps_audio_mpeg,
       git: "git@github.com:membraneframework/membrane-caps-audio-mpeg.git"},
      {:espec, "~> 1.5", only: :test}
    ]
  end
end
