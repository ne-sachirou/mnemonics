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
      def load(version), do: GenServer.call Mnemonics.Repo, {:load_table, unquote(table_name), version}

      @doc """
      Get a latest table reference.
      """
      @spec table_name :: :ets.tid
      def table_name do
        {_, %{tid: tid}} = Mnemonics.Repo.tables
          |> Enum.filter(&(elem(&1, 1).table_name == unquote(table_name)))
          |> Enum.max_by(&elem(&1, 1).version)
        tid
      end

      @doc """
      Get a table reference of the version.
      """
      @spec table_name(non_neg_integer) :: :ets.tid
      def table_name(version) do
        {_, %{tid: tid}} = Enum.find Mnemonics.Repo.tables, fn {_, memory} ->
          memory.table_name == unquote(table_name) and memory.version == version
        end
        tid
      end
    end
  end
end
