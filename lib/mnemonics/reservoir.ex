defmodule Mnemonics.Reservoir do
  @moduledoc """
  Supervise Mnemonics.Memory
  """

  use Supervisor

  @doc false
  @spec start_link(term) :: Supervisor.on_start
  def start_link(arg), do: Supervisor.start_link __MODULE__, arg, name: __MODULE__

  @doc false
  @spec init([term]) :: {:ok, {:supervisor.sup_flags, [:supervisor.child_spec]}}
  def init(_arg) do
    Supervisor.init [
      Supervisor.child_spec(Mnemonics.Memory, []),
    ], strategy: :simple_one_for_one
  end
end
