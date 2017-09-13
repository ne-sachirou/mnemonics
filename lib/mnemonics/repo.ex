defmodule Mnemonics.Repo do
  @moduledoc """
  """

  use GenServer

  @type t :: %__MODULE__{
    tables: [{atom, non_neg_integer, pid}]
  }

  @living_versions 2

  defstruct tables: []

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
  @spec handle_call({:load_table, atom, non_neg_integer}, GenServer.from, t) :: {:reply, :ok | {:error, term}, t}
  def handle_call({:load_table, table_name, version}, _from, state) do
    {existing_tables, old_tables, rest_tables} = state.tables
      |> Enum.sort_by(fn {_, version, _} -> version end, &>=/2)
      |> Enum.reduce({[], [], []}, fn
        {^table_name, ^version, _} = table, {existing_tables, old_tables, rest_tables} ->
          {existing_tables, [table | old_tables], rest_tables}
        {^table_name, _, _} = table, {existing_tables, old_tables, rest_tables}
          when length(existing_tables) >= @living_versions - 1 ->
          {existing_tables, [table | old_tables], rest_tables}
        {^table_name, _, _} = table, {existing_tables, old_tables, rest_tables} ->
          {[table | existing_tables], old_tables, rest_tables}
        table, {existing_tables, old_tables, rest_tables} ->
          {existing_tables, old_tables, [table | rest_tables]}
      end)
    for {_, _, memory} <- old_tables do
      try do
        GenServer.call memory, :stop
      catch
        :exit, {:normal, _} -> :normal
      end
    end
    case Supervisor.start_child Mnemonics.Reservoir, [[table_name: table_name, version: version]] do
      {:ok, memory} ->
        state = put_in state.tables, [{table_name, version, memory} | existing_tables ++ rest_tables]
        {:reply, :ok, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @doc """
  """
  @spec handle_call(:tables, GenServer.from, t) :: {:reply, [{atom, non_neg_integer, pid}], t}
  def handle_call(:tables, _from, %{tables: tables} = state), do: {:reply, tables, state}

  @doc """
  """
  @spec table_name(atom, non_neg_integer) :: atom
  def table_name(table_name, version), do: :"#{table_name}:#{version}"
end
