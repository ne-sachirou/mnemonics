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
    quote do
      @doc """
      Load an ETS table from file.
      """
      @spec load(non_neg_integer) :: :ok | {:error, term}
      def load(version), do: GenServer.call Mnemonics.Repo, {:load_table, __MODULE__, unquote(table_name), version}

      @doc """
      Get a latest table.
      """
      @spec table :: Mnemonics.Memory.t
      def table do
        Mnemonics.Repo.tables
        |> Enum.filter(&(elem(&1, 1).table_name == unquote(table_name)))
        |> Enum.max_by(&elem(&1, 1).version)
        |> elem(1)
      end

      @doc """
      Get a table of the version.
      """
      @spec table(non_neg_integer) :: Mnemonics.Repo.t
      def table(version) do
        Mnemonics.Repo.tables
        |> Enum.find(fn {_, memory} ->
          memory.table_name == unquote(table_name) and memory.version == version
        end)
        |> elem(1)
      end

      @doc """
      Get a latest table reference.
      """
      @spec table_name :: :ets.tid
      def table_name, do: table().tid

      @doc """
      Get a table reference of the version.
      """
      @spec table_name(non_neg_integer) :: :ets.tid
      def table_name(version), do: table(version).tid
    end
  end
end
