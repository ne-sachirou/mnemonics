defmodule Mnemonics do
  @moduledoc """
  Read only data store for Elixir: fast, concurrently, for large data & hot reloadable.

      iex> Example.create_example_ets :mnemonics_example
      iex> defmodule MnemonicsExample do
      iex>   use Mnemonics, table_name: :mnemonics_example
      iex> end
      iex> MnemonicsExample.load 1
      :ok
      iex> :ets.lookup MnemonicsExample.table_name(1), 1
      [{1, %Mnemonics.Example{id: 1, name: "1"}}]
  """

  use Supervisor

  @spec start_link(keyword) :: Supervisor.on_start()
  def start_link(arg) do
    arg = arg |> put_in([:sup_name], arg[:name] || __MODULE__) |> Keyword.delete(:name)
    Supervisor.start_link(__MODULE__, arg)
  end

  @impl true
  def init(arg) do
    unless Keyword.has_key?(arg, :ets_dir), do: raise(":ets_dir is required.")

    children = [
      {Mnemonics.Repo, put_in(arg[:name], Module.concat(arg[:sup_name], Repo))},
      {Mnemonics.Reservoir, put_in(arg[:name], Module.concat(arg[:sup_name], Reservoir))}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defmacro __using__(opts) do
    table_name = Keyword.fetch!(opts, :table_name)
    sup_name = opts[:sup_name] || Mnemonics
    global_tables_key = Mnemonics.Repo.global_tables_key(sup_name)

    quote location: :keep do
      @doc """
      Load an ETS table from file.

      opts:

      * `timeout:` Timeout ms (default 5000).
      """
      @spec load(pos_integer, keyword) :: :ok | {:error, term}
      def load(version, opts \\ []) do
        GenServer.call(
          Module.concat(unquote(sup_name), Repo),
          {:load_table, __MODULE__, unquote(table_name), version},
          opts[:timeout] || 5000
        )
      end

      @doc """
      Take version snapshot of the table.
      """
      @spec snap(Mnemonics.Snap.t()) :: Mnemonics.Snap.t()
      def snap(snap), do: snap(snap, table().version)

      @spec snap(Mnemonics.Snap.t(), pos_integer) :: Mnemonics.Snap.t()
      def snap(snap, version), do: Mnemonics.Snap.snap(snap, unquote(table_name), version)

      @doc """
      Get a table of some version.
      """
      @spec table :: Mnemonics.Memory.t()
      def table do
        memories =
          for memory <- Mnemonics.Repo.tables({FastGlobal, unquote(global_tables_key)}),
              memory.table_name == unquote(table_name),
              do: memory

        Enum.max_by(memories, & &1.version)
      end

      @spec table(Mnemonics.Snap.t()) :: Mnemonics.Memory.t()
      def table(%Mnemonics.Snap{} = snap), do: table(snap.versions[unquote(table_name)])

      @spec table(pos_integer) :: Mnemonics.Memory.t()
      def table(version) do
        case Enum.find(
               Mnemonics.Repo.tables({FastGlobal, unquote(global_tables_key)}),
               fn
                 %{table_name: unquote(table_name), version: ^version} -> true
                 _ -> false
               end
             ) do
          nil -> raise "There's no table {#{unquote(table_name)}, #{version}}."
          memory -> memory
        end
      end

      @doc """
      Get a table reference of some version.
      """
      @spec table_name :: :ets.tid()
      def table_name, do: table().tid

      @spec table_name(Mnemonics.Snap.t()) :: :ets.tid()
      def table_name(%Mnemonics.Snap{} = snap), do: table(snap).tid

      @spec table_name(pos_integer) :: :ets.tid()
      def table_name(version), do: table(version).tid
    end
  end
end
