defmodule Mnemonics do
  @moduledoc """
  """

  alias Mnemonics.Repo

  @doc """
  """
  @spec reload :: any
  def reload do
    for {table_name, memory} <- GenServer.call(Mnemonics.Repo, :tables) do
      GenServer.call memory, :stop
      Repo.load_table table_name
    end
  end

  @doc """
  """
  @spec reload([atom] | atom) :: any
  def reload(table_names) when is_list(table_names) do
    for {table_name, memory} <- GenServer.call(Mnemonics.Repo, :tables), table_name in table_names do
      GenServer.call memory, :stop
      Repo.load_table table_name
    end
  end
  def reload(table_name), do: reload [table_name]

  defmacro __using__(table_name: table_name) do
    quote do
      @doc """
      """
      @spec load :: any
      def load, do: Mnemonics.Repo.load_table unquote table_name

      @doc """
      """
      @spec table_name :: atom
      def table_name, do: unquote table_name
    end
  end
end
