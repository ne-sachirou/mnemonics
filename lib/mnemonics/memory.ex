defmodule Mnemonics.Memory do
  @moduledoc """
  """

  alias Mnemonics.Repo

  use GenServer

  @type t :: %{
    table_name: atom,
    version: non_neg_integer,
  }

  defstruct table_name: nil, version: 0

  @doc """
  """
  @spec start_link(any, term) :: GenServer.on_start
  def start_link(_, arg), do: GenServer.start_link __MODULE__, arg

  @doc """
  """
  @spec init([table_name: atom, version: non_neg_integer]) :: {:ok, t} | {:stop, :ets.tab | term}
  def init(table_name: table_name, version: version) do
    case [Application.get_env(:mnemonics, :ets_dir), "#{table_name}.ets"]
           |> Path.join
           |> String.to_charlist
           |> :ets.file2tab do
      {:ok, table} ->
        :ets.rename table, Repo.table_name(table_name, version)
        {:ok, %__MODULE__{table_name: table_name, version: version}}
      {:error, reason} -> {:stop, reason}
    end
  end

  @doc """
  """
  @spec terminate(:normal | :shutdown | {:shutdown, term} | term, t) :: term
  def ternimate(_reason, _state), do: :ok

  @doc """
  """
  @spec handle_call(:stop, GenServer.from, t) :: {:stop, :normal, t}
  def handle_call(:stop, _from, state) do
    :ets.delete Repo.table_name(state.table_name, state.version)
    {:stop, :normal, state}
  end
end
