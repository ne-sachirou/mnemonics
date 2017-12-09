defmodule Mnemonics.Repo do
  @moduledoc """
  Orchestrate `Mnemonics.Memory`.
  """

  alias Mnemonics.Memory

  use GenServer

  @type table :: {pid, Memory.t}

  @type t :: %__MODULE__{
    tables: [table]
  }

  @global_tables_default_value :erlang.term_to_binary []

  @global_tables_key FastGlobal.new :"#{__MODULE__}.Tables}"

  @living_versions 2

  defstruct tables: []

  @doc false
  @spec start_link(term) :: GenServer.on_start
  def start_link(arg), do: GenServer.start_link __MODULE__, arg, name: __MODULE__

  @doc false
  @spec init(term) :: {:ok, t}
  def init(_arg) do
    FastGlobal.put @global_tables_key, @global_tables_default_value
    {:ok, %__MODULE__{}}
  end

  @doc """
  All living tables.
  """
  @spec tables :: [table]
  def tables, do: @global_tables_key |> FastGlobal.get(@global_tables_default_value) |> :erlang.binary_to_term

  @doc """
  `:load_table` => Load a table of the table_name & version, then stop old ones.
  """
  @spec handle_call({:load_table, atom, atom, pos_integer}, GenServer.from, t) :: {:reply, :ok | {:error, term}, t}
  def handle_call({:load_table, module, table_name, version}, _from, state) do
    case Supervisor.start_child Mnemonics.Reservoir, [[module: module, table_name: table_name, version: version]] do
      {:ok, memory_pid} ->
        memory = GenServer.call memory_pid, :state
        {old_tables, state} = get_and_update_in state.tables, fn tables ->
          {old_tables, tables} = pop_old_tables tables, table_name, version
          {old_tables, [{memory_pid, memory} | tables]}
        end
        # NOTE: FastGlobal can't put pid & reference.
        FastGlobal.put @global_tables_key, :erlang.term_to_binary(state.tables)
        for {memory_pid, _} <- old_tables do
          try do
            GenServer.call memory_pid, :stop
          catch
            :exit, {:normal, _} -> nil
          end
        end
        {:reply, :ok, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @doc false
  @spec handle_call({:call_memory, Memory.t, term}, GenServer.from, t) :: {:reply, any | {:error, any}, t}
  def handle_call({:call_memory, memory, message}, from, state) do
    case Enum.find state.tables, &match?({_, ^memory}, &1) do
      {pid, _} ->
        Task.start fn ->
          try do
            GenServer.reply from, GenServer.call(pid, message)
          rescue
            error -> GenServer.reply from, {:error, error}
          catch
            :exit, {:normal, _} -> nil
            kind, reason -> GenServer.reply from, {:error, {kind, reason}}
          end
        end
        {:noreply, state}
      _ -> {:reply, {:error, "Mnemonics.Repo: Memory not found."}, state}
    end
  end

  @spec pop_old_tables([table], atom, pos_integer) :: {[table], [table]}
  defp pop_old_tables(tables, table_name, version) do
    {existing_tables, old_tables, rest_tables} = tables
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
    {old_tables, existing_tables ++ rest_tables}
  end
end
