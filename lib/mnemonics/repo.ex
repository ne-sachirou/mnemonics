defmodule Mnemonics.Repo do
  @moduledoc """
  """

  use GenServer

  @type t :: %__MODULE__{
    tables: %{atom => pid},
  }

  defstruct tables: %{}

  @doc """
  """
  @spec start_link(term) :: GenServer.on_start
  def start_link(arg), do: GenServer.start_link __MODULE__, arg, name: __MODULE__

  @doc """
  """
  @spec init(term) :: {:ok, t}
  def init(_arg), do: {:ok, %__MODULE__{}}

  @doc """
  """
  @spec load_table(atom) :: any
  def load_table(table_name) do
    {:ok, memory} = Supervisor.start_child Mnemonics.Reservoir, [[table_name: table_name]]
    GenServer.call __MODULE__, {:register, table_name, memory}
  end

  @doc """
  """
  @spec handle_call({:register, atom, pid}, GenServer.from, t) :: {:reply, :ok, t}
  def handle_call({:register, table_name, memory}, _from, state) do
    state = put_in state.tables[table_name], memory
    {:reply, :ok, state}
  end

  @doc """
  """
  @spec handle_call(:tables, GenServer.from, t) :: {:reply, %{atom => pid}, t}
  def handle_call(:tables, _from, %{tables: tables} = state), do: {:reply, tables, state}
end
