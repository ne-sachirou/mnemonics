defmodule Mnemonics.Repo do
  @moduledoc """
  Orchestrate `Mnemonics.Memory`.
  """

  alias Mnemonics.Memory
  alias Mnemonics.Reservoir

  use GenServer

  @type t :: %__MODULE__{
          sup_name: atom,
          ets_dir: binary,
          tables: [Memory.t()]
        }

  @global_tables_default_value :erlang.term_to_binary([])

  @living_versions 2

  defstruct sup_name: nil, ets_dir: "", tables: []

  @doc false
  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(arg), do: GenServer.start_link(__MODULE__, arg, name: arg[:name])

  @doc false
  @impl true
  @spec init(keyword) :: {:ok, t}
  def init(arg) do
    global_tables_key = Module.concat(arg[:name], Tables)
    :persistent_term.put(global_tables_key, @global_tables_default_value)
    {:ok, %__MODULE__{sup_name: arg[:sup_name], ets_dir: arg[:ets_dir]}}
  end

  @doc """
  All living tables.
  """
  @spec tables(term) :: [Memory.t()]
  def tables(sup_name \\ Mnemonics)

  def tables({:persistent_term, global_tables_key}),
    do: :persistent_term.get(global_tables_key, @global_tables_default_value)

  def tables(sup_name), do: tables({:persistent_term, global_tables_key(sup_name)})

  def global_tables_key(sup_name), do: Module.concat(sup_name, Repo.Tables)

  @doc """
  `:load_table` => Load a table of the table_name & version, then stop old ones.
  """
  @impl true
  @spec handle_call({:load_table, module, atom, pos_integer}, GenServer.from(), t) ::
          {:reply, :ok | {:error, term}, t}
  def handle_call({:load_table, module, table_name, version}, _from, state) do
    case Reservoir.start_child(state.sup_name,
           module: module,
           table_name: table_name,
           version: version,
           ets_dir: state.ets_dir
         ) do
      {:ok, memory_pid} ->
        memory = GenServer.call(memory_pid, :state)

        {old_tables, state} =
          get_and_update_in(state.tables, fn tables ->
            {old_tables, tables} = pop_old_tables(tables, table_name, version)
            {old_tables, [memory | tables]}
          end)

        :persistent_term.put(global_tables_key(state.sup_name), state.tables)

        for memory <- old_tables do
          try do
            GenServer.call(memory.pid, :stop)
          catch
            :exit, {:normal, _} -> nil
          end
        end

        {:reply, :ok, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @spec pop_old_tables([Memory.t()], atom, pos_integer) :: {[Memory.t()], [Memory.t()]}
  defp pop_old_tables(tables, table_name, version) do
    {existing_tables, old_tables, rest_tables} =
      tables
      |> Enum.sort_by(& &1.version, &>=/2)
      |> Enum.reduce({[], [], []}, fn
        %{table_name: ^table_name, version: ^version} = table,
        {existing_tables, old_tables, rest_tables} ->
          {existing_tables, [table | old_tables], rest_tables}

        %{table_name: ^table_name} = table, {existing_tables, old_tables, rest_tables}
        when length(existing_tables) >= @living_versions - 1 ->
          {existing_tables, [table | old_tables], rest_tables}

        %{table_name: ^table_name} = table, {existing_tables, old_tables, rest_tables} ->
          {[table | existing_tables], old_tables, rest_tables}

        table, {existing_tables, old_tables, rest_tables} ->
          {existing_tables, old_tables, [table | rest_tables]}
      end)

    {old_tables, existing_tables ++ rest_tables}
  end
end
