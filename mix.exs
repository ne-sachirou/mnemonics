defmodule Mnemonics.Mixfile do
  use Mix.Project

  @github "https://github.com/ne-sachirou/mnemonics"

  def project do
    [
      app: :mnemonics,
      deps: deps(),
      description:
        "Read only data store for Elixir: fast, concurrently, for large data & hot reloadable.",
      dialyzer: [
        flags: [:no_undefined_callbacks],
        ignore_warnings: "dialyzer.ignore-warnings",
        remove_defaults: [:unknown]
      ],
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.github": :test,
        "coveralls.html": :test
      ],
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "0.5.1",

      # Docs
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
      homepage_url: @github,
      name: "Mnemonics",
      source_url: @github
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:fastglobal, "~> 1.0"},
      {:inner_cotton, github: "ne-sachirou/inner_cotton", only: [:dev, :test]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def package do
    [
      files: ["LICENSE", "README.md", "mix.exs", "lib"],
      licenses: ["GPL-3.0-or-later"],
      links: %{GitHub: @github},
      maintainers: ["ne_Sachirou <utakata.c4se@gmail.com>"],
      name: :mnemonics
    ]
  end
end
