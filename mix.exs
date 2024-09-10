defmodule MutableMap.MixProject do
  use Mix.Project

  @version "1.0.1"
  @name "MutableMap"
  @url "https://github.com/dominicletz/mutable_map"
  @maintainers ["Dominic Letz"]

  def project do
    [
      app: :mutable_map,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      version: @version,
      name: @name,
      docs: docs(),
      package: package(),
      homepage_url: @url,
      description: """
      Mutable maps for Elixir. These are based on ETS tables but are
      automatically garbage collected when not reference to the MutableMap
      exists anymore.
      """
    ]
  end

  def application do
    [
      mod: {MutableMap.Beacon, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:weak_ref, "~> 1.0.0"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: @name,
      source_ref: "v#{@version}",
      source_url: @url,
      authors: @maintainers
    ]
  end

  defp package do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{github: @url},
      files: ~w(lib LICENSE.md mix.exs README.md)
    ]
  end
end
