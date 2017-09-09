defmodule Mnemonics.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # import Supervisor.Spec
    children = [
      {Mnemonics.Repo, []},
      # worker(Mnemonics.Repo, []),
      {Mnemonics.Reservoir, []},
    ]
    opts = [strategy: :one_for_one, name: Mnemonics.Supervisor]
    Supervisor.start_link children, opts
  end
end
