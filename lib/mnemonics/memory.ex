defmodule Mnemonics.Memory do
  @moduledoc """
  """

  use GenServer

  @type t :: %{
    tid: :ets.tid,
    table_name: atom,
    version: non_neg_integer,
  }

  defstruct tid: nil, table_name: nil, version: 0

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
      {:ok, table} -> {:ok, %__MODULE__{tid: table, table_name: table_name, version: version}}
      {:error, reason} -> {:stop, reason}
    end
  end

  @doc """
  """
  @spec terminate(:normal | :shutdown | {:shutdown, term} | term, t) :: term
  def ternimate(_reason, _state), do: :ok

  @doc """
  """
  @spec handle_call(:state, GenServer.from, t) :: {:reply, t, t}
  def handle_call(:state, _from, t), do: {:reply, t, t}

  @doc """
  """
  @spec handle_call(:stop, GenServer.from, t) :: {:stop, :normal, t}
  def handle_call(:stop, _from, state) do
    :ets.delete state.tid
    {:stop, :normal, state}
  end
end
