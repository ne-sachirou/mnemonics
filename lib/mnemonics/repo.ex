defmodule Mnemonics.Repo do
  @moduledoc """
  """

  alias Mnemonics.Memory

  use GenServer

  @type t :: %__MODULE__{
    tables: [{pid, Memory.t}]
  }

  @global_tables_key FastGlobal.new :"#{__MODULE__}.Tables}"
  @living_versions 2

  defstruct tables: []

  @doc """
  """
  @spec start_link(term) :: GenServer.on_start
  def start_link(arg), do: GenServer.start_link __MODULE__, arg, name: __MODULE__

  @doc """
  """
  @spec init(term) :: {:ok, t}
  def init(_arg) do
    FastGlobal.put @global_tables_key, []
    {:ok, %__MODULE__{}}
  end

  @spec tables :: [{pid, Memory.t}]
  def tables, do: @global_tables_key |> FastGlobal.get([]) |> Enum.map(&:erlang.binary_to_term/1)

  @doc """
  """
  @spec handle_call({:load_table, atom, non_neg_integer}, GenServer.from, t) :: {:reply, :ok | {:error, term}, t}
  def handle_call({:load_table, table_name, version}, _from, state) do
    {existing_tables, old_tables, rest_tables} = state.tables
      |> Enum.sort_by(fn {_, %{version: version}} -> version end, &>=/2)
      |> Enum.reduce({[], [], []}, fn
        {_, %{table_name: ^table_name, version: ^version}} = table, {existing_tables, old_tables, rest_tables} ->
          {existing_tables, [table | old_tables], rest_tables}
        {_, %{table_name: ^table_name}} = table, {existing_tables, old_tables, rest_tables}
          when length(existing_tables) >= @living_versions - 1 ->
          {existing_tables, [table | old_tables], rest_tables}
        {_, %{table_name: ^table_name}} = table, {existing_tables, old_tables, rest_tables} ->
          {[table | existing_tables], old_tables, rest_tables}
        table, {existing_tables, old_tables, rest_tables} ->
          {existing_tables, old_tables, [table | rest_tables]}
      end)
    for {memory_pid, _} <- old_tables do
      try do
        GenServer.call memory_pid, :stop
      catch
        :exit, {:normal, _} -> :normal
      end
    end
    case Supervisor.start_child Mnemonics.Reservoir, [[table_name: table_name, version: version]] do
      {:ok, memory_pid} ->
        memory = GenServer.call memory_pid, :state
        state = put_in state.tables, [{memory_pid, memory} | existing_tables ++ rest_tables]
        # NOTE: FastGlobal can't put pid & reference.
        FastGlobal.put @global_tables_key, Enum.map(state.tables, &:erlang.term_to_binary/1)
        {:reply, :ok, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end
end
