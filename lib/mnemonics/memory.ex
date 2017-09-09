defmodule Mnemonics.Memory do
  @moduledoc """
  """

  use GenServer

  @type t :: %{
    table_name: atom,
  }

  defstruct table_name: nil

  @doc """
  """
  @spec start_link(any, term) :: GenServer.on_start
  def start_link(_, arg), do: GenServer.start_link __MODULE__, arg

  @doc """
  """
  @spec init([table_name: atom]) :: {:ok, t} | {:stop, :ets.tab | term}
  def init(table_name: table_name) do
    case [Application.get_env(:mnemonics, :ets_dir), "#{table_name}.ets"]
         |> Path.join
         |> String.to_charlist
         |> :ets.file2tab do
      {:ok, ^table_name} -> {:ok, %__MODULE__{table_name: table_name}}
      {:ok, tab} -> {:stop, tab}
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
    :ets.delete state.table_name
    {:stop, :normal, state}
  end
end
