defmodule Mnemonics.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mnemonics,
      deps: deps(),
      description: "Read only data store for Elixir: fast, concurrently, for large data & hot reloadable.",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
      ],
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "0.2.0",

      # Docs
      docs: [
        main: "readme",
        extras: ["README.md"],
      ],
      homepage_url: "https://github.com/ne-sachirou/mnemonics",
      name: "Mnemonics",
      source_url: "https://github.com/ne-sachirou/mnemonics",
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
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:fastglobal, "~> 1.0"},
      {:inner_cotton, github: "ne-sachirou/inner_cotton", only: [:dev, :test]},
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def package do
    [
      files: ["LICENSE", "README.md", "mix.exs", "lib"],
      licenses: ["GPL-3.0"],
      links: %{
        "GitHub": "https://github.com/ne-sachirou/mnemonics",
      },
      maintainers: ["ne_Sachirou <utakata.c4se@gmail.com>"],
      name: :mnemonics,
    ]
  end
end
