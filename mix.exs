defmodule Mnemonics.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mnemonics,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env),
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Mnemonics.Application, []}
    ]
  end

  defp deps do
    [
      {:fastglobal, "~> 1.0"},
      {:inner_cotton, github: "ne-sachirou/inner_cotton", only: [:dev, :test], runtime: false},
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
