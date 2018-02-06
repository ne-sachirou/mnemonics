defmodule Example.Application do
  @moduledoc """
  The Example Application Service.

  The example system business domain lives in this application.

  Exposes API to clients such as the `ExampleWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      supervisor(Example.Repo, []),
    ], strategy: :one_for_one, name: Example.Supervisor)
  end
end
