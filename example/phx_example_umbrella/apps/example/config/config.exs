use Mix.Config

config :example, ecto_repos: [Example.Repo]

import_config "#{Mix.env}.exs"
