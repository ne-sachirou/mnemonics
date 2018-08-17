defmodule Mnemonics.Reservoir do
  @moduledoc """
  Supervise `Mnemonics.Memory`.
  """

  use DynamicSupervisor

  alias Mnemonics.Memory

  @doc false
  @spec start_link(keyword) :: Supervisor.on_start()
  def start_link(arg), do: DynamicSupervisor.start_link(__MODULE__, arg, name: arg[:name])

  @doc false
  def init(_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

  @doc """
  Start a Memory.
  """
  @spec start_child(atom, Memory.init_args()) :: Supervisor.on_start_child()
  def start_child(sup_name, arg),
    do: DynamicSupervisor.start_child(Module.concat(sup_name, Reservoir), {Memory, arg})
end
