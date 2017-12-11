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

  defmacro __using__(table_name: table_name) do
    quote location: :keep do
      @doc """
      Load an ETS table from file.
      """
      @spec load(pos_integer) :: :ok | {:error, term}
      def load(version), do: GenServer.call Mnemonics.Repo, {:load_table, __MODULE__, unquote(table_name), version}

      @doc """
      Take version snapshot of the table.
      """
      @spec snap(Mnemonics.Snap.t) :: Mnemonics.Snap.t
      def snap(snap), do: snap snap, table().version

      @spec snap(Mnemonics.Snap.t, pos_integer) :: Mnemonics.Snap.t
      def snap(snap, version), do: Mnemonics.Snap.snap snap, unquote(table_name), version

      @doc """
      Get a table of some version.
      """
      @spec table :: Mnemonics.Memory.t
      def table do
        memories =
          for memory <- Mnemonics.Repo.tables,
            memory.table_name == unquote(table_name),
            do: memory
        Enum.max_by memories, &(&1).version
      end

      @spec table(Mnemonics.Snap.t) :: Mnemonics.Memory.t
      def table(%Mnemonics.Snap{} = snap), do: table snap.versions[unquote(table_name)]

      @spec table(pos_integer) :: Mnemonics.Memory.t
      def table(version) do
        memory = Enum.find Mnemonics.Repo.tables, fn memory ->
          memory.table_name == unquote(table_name) and memory.version == version
        end
        memory
      end

      @doc """
      Get a table reference of some version.
      """
      @spec table_name :: :ets.tid
      def table_name, do: table().tid

      @spec table_name(Mnemonics.Snap.t) :: :ets.tid
      def table_name(%Mnemonics.Snap{} = snap), do: table(snap).tid

      @spec table_name(pos_integer) :: :ets.tid
      def table_name(version), do: table(version).tid
    end
  end
end
