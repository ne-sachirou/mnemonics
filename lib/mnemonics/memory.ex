defmodule Mnemonics.Memory do
  @moduledoc """
  Own an ETS.
  """

  use GenServer

  @type t :: %{
          tid: :ets.tid(),
          pid: pid,
          module: module,
          table_name: atom,
          version: pos_integer
        }

  @type init_args :: [
          module: module,
          table_name: atom,
          version: pos_integer
        ]

  defstruct tid: nil, pid: nil, module: nil, table_name: nil, version: 0

  @doc false
  # For Elixir >= 1.6
  @spec start_link(term) :: GenServer.on_start()
  def start_link(arg), do: GenServer.start_link(__MODULE__, arg)
  # For Elixir 1.5
  @spec start_link(any, term) :: GenServer.on_start()
  def start_link(_, arg), do: GenServer.start_link(__MODULE__, arg)

  @doc false
  @spec init(init_args) :: {:ok, t} | {:stop, :ets.tab() | term}
  def init(module: module, table_name: table_name, version: version) do
    case [Application.get_env(:mnemonics, :ets_dir), "#{table_name}.ets"]
         |> Path.join()
         |> String.to_charlist()
         |> :ets.file2tab() do
      {:ok, tid} ->
        {:ok,
         %__MODULE__{
           tid: tid,
           pid: self(),
           module: module,
           table_name: table_name,
           version: version
         }}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @doc false
  @spec terminate(:normal | :shutdown | {:shutdown, term} | term, t) :: term
  def terminate(_reason, _state), do: :ok

  @doc """
  `:state` => Reply the state.

  `:stop` => Delete the ETS & stop.
  """
  @spec handle_call(:state, GenServer.from(), t) :: {:reply, t, t}
  def handle_call(:state, _from, t), do: {:reply, t, t}

  @spec handle_call(:stop, GenServer.from(), t) :: {:stop, :normal, t}
  def handle_call(:stop, _from, state) do
    :ets.delete(state.tid)
    {:stop, :normal, state}
  end

  @spec handle_call({:write, (t -> any)}, GenServer.from(), t) :: {:reply, any | {:error, any}, t}
  def handle_call({:write, callback}, _from, state) do
    :ets.safe_fixtable(state.tid, true)
    {:reply, callback.(state), state}
  rescue
    error -> {:reply, {:error, error}, state}
  after
    :ets.safe_fixtable(state.tid, false)
  end
end
