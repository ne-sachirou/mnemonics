defmodule Benchmark.MixProject do
  use Mix.Project

  def project do
    [
      app: :benchmark,
      deps: deps(),
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps do
    [
      {:benchee, "~> 1.0"},
      {:fastglobal, "~> 1.0"},
      {:mnemonics, path: ".."}
    ]
  end
end
