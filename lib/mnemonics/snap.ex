defmodule Mnemonics.Snap do
  @moduledoc """
  Snapshot of tables.

      iex> snap = Mnemonics.Snap.new
      %Mnemonics.Snap{versions: %{}, cache: %{}}
      iex> snap = Mnemonics.Snap.snap snap, :examples, 1
      %Mnemonics.Snap{versions: %{examples: 1}, cache: %{examples: %{}}}
      iex> snap[:examples].version
      1
      iex> get_and_update_in snap[:examples].cache[1], fn value ->
      iex>   value = value || "example 1"
      iex>   {value, value}
      iex> end
      {"example 1", %Mnemonics.Snap{versions: %{examples: 1}, cache: %{examples: %{1 => "example 1"}}}}
  """

  @behaviour Access

  @type table_snap :: %{version: pos_integer, cache: term}

  @type t :: %__MODULE__{
          versions: %{atom => pos_integer},
          cache: %{atom => term}
        }

  defstruct versions: %{}, cache: %{}

  @doc """
  Create a new snap.

      iex> Mnemonics.Snap.new
      %Mnemonics.Snap{versions: %{}, cache: %{}}
  """
  @spec new :: t
  def new, do: %__MODULE__{}

  @doc """
  Snap the table with the version.

      iex> snap = Mnemonics.Snap.new
      iex> Mnemonics.Snap.snap snap, :examples, 1
      %Mnemonics.Snap{versions: %{examples: 1}, cache: %{examples: %{}}}

      iex> snap = Mnemonics.Snap.new
      iex> put_in snap[:examples], %{version: 1}
      %Mnemonics.Snap{versions: %{examples: 1}, cache: %{examples: %{}}}
  """
  @spec snap(t, atom, pos_integer, term) :: t
  def snap(snap, table_name, version, cache \\ %{}),
    do: put_in(snap[table_name], %{version: version, cache: cache})

  @doc false
  @spec fetch(t, atom) :: {:ok, table_snap} | :error
  def fetch(snap, table_name) do
    case snap.versions[table_name] do
      nil -> :error
      version -> {:ok, %{version: version, cache: snap.cache[table_name]}}
    end
  end

  @doc false
  @spec get(t, atom, any) :: table_snap | any
  def get(snap, table_name, default) do
    case fetch(snap, table_name) do
      {:ok, value} -> value
      :error -> default
    end
  end

  @doc false
  @spec get_and_update(t, atom, (table_snap -> {any, table_snap} | :pop)) :: {any, t}
  def get_and_update(snap, table_name, function) do
    {get_value, table_snap} = function.(snap[table_name])

    %{version: version, cache: cache} =
      table_snap
      |> update_in([:version], &(&1 || 1))
      |> update_in([:cache], &(&1 || %{}))

    snap = put_in(snap.versions[table_name], version)
    snap = put_in(snap.cache[table_name], cache)
    {get_value, snap}
  end

  @doc false
  @spec pop(t, atom) :: {table_snap, t}
  def pop(snap, table_name) do
    table_snap = snap[table_name]
    {_, snap} = pop_in(snap.versions[table_name])
    {_, snap} = pop_in(snap.cache[table_name])
    {table_snap, snap}
  end
end
