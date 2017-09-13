defmodule Mnemonics do
  @moduledoc """
  """

  defmacro __using__(table_name: table_name) do
    quote do
      @doc """
      """
      @spec load(non_neg_integer) :: any
      def load(version), do: GenServer.call Mnemonics.Repo, {:load_table, unquote(table_name), version}

      @doc """
      """
      @spec table_name :: atom
      def table_name do
        {_, %{tid: tid}} = Mnemonics.Repo
          |> GenServer.call(:tables)
          |> Enum.filter(&(elem(&1, 1).table_name == unquote(table_name)))
          |> Enum.max_by(&elem(&1, 1).version)
        tid
      end

      @doc """
      """
      @spec table_name(non_neg_integer) :: atom
      def table_name(version) do
        {_, %{tid: tid}} = Mnemonics.Repo
          |> GenServer.call(:tables)
          |> Enum.find(fn {_, memory} -> memory.table_name == unquote(table_name) and memory.version == version end)
        tid
      end
    end
  end
end
