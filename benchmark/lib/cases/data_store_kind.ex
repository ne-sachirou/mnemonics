defmodule Benchmark.Cases.DataStoreKind do
  @moduledoc """
  Compare the speed of data stores.
  """

  @doc """
  """
  def run do
    scenarios =
      for name <- ~w(empty ets fast_global gen_server heap persistent_term), into: %{} do
        {name,
         {
           parallel(fn {param, size} ->
             apply(__MODULE__, String.to_existing_atom("run_#{name}"), [param, size])
           end),
           before_scenario: fn data ->
             {apply(__MODULE__, String.to_existing_atom("prepare_#{name}"), [data]),
              map_size(data)}
           end,
           after_scenario: fn {param, _} ->
             apply(__MODULE__, String.to_existing_atom("cleanup_#{name}"), [param])
           end
         }}
      end

    Benchee.run(
      scenarios,
      inputs: %{
        "100" => generate_data(100),
        "1_000" => generate_data(1_000),
        "10_000" => generate_data(10_000),
        "100_000" => generate_data(100_000)
      },
      memory_time: 2,
      time: 10
    )
  end

  def prepare_empty(_data), do: nil

  def run_empty(_, size) do
    for _ <- 1..100_000, do: :rand.uniform(size)
  end

  def cleanup_empty(_), do: nil

  def prepare_ets(data) do
    tid = :ets.new(:test, [:set, :protected, read_concurrency: true])
    :ets.insert_new(tid, Map.to_list(data))
    tid
  end

  def run_ets(tid, size) do
    for _ <- 1..100_000 do
      item = :ets.lookup_element(tid, :rand.uniform(size), 2)
      item.name
      item.callback
    end
  end

  def cleanup_ets(tid), do: :ets.delete(tid)

  def prepare_fast_global(data) do
    data =
      for {id, item} <- data, into: %{} do
        item = update_in(item.callback, &:erlang.term_to_binary(&1))
        {id, item}
      end

    FastGlobal.put(__MODULE__, data)
  end

  def run_fast_global(_, size) do
    for _ <- 1..100_000 do
      item = FastGlobal.get(__MODULE__)[:rand.uniform(size)]
      item.name
      :erlang.binary_to_term(item.callback)
    end
  end

  def cleanup_fast_global(_), do: FastGlobal.put(__MODULE__, nil)

  def prepare_gen_server(data), do: elem(GenServer.start_link(__MODULE__.GenServer, data), 1)

  def run_gen_server(pid, size) do
    for _ <- 1..100_000 do
      item = GenServer.call(pid, {:lookup, :rand.uniform(size)})
      item.name
      item.callback
    end
  end

  def cleanup_gen_server(pid), do: GenServer.stop(pid)

  def prepare_heap(data), do: data

  def run_heap(data, size) do
    for _ <- 1..100_000 do
      item = data[:rand.uniform(size)]
      item.name
      item.callback
    end
  end

  def cleanup_heap(_), do: nil

  def prepare_persistent_term(data), do: :persistent_term.put(__MODULE__, data)

  def run_persistent_term(_, size) do
    for _ <- 1..100_000 do
      item = :persistent_term.get(__MODULE__)[:rand.uniform(size)]
      item.name
      item.callback
    end
  end

  def cleanup_persistent_term(_), do: :persistent_term.erase(__MODULE__)

  defp generate_data(size) do
    for i <- 1..size, into: %{} do
      item = %{id: i, name: "item #{i}", callback: fn n -> n + 1 end}
      {i, item}
    end
  end

  def parallel(fun) do
    fn arg ->
      1..System.schedulers_online()
      |> Task.async_stream(fn _ -> fun.(arg) end, ordered: false, timeout: 10 * 1000)
      |> Stream.run()
    end
  end
end

defmodule Benchmark.Cases.DataStoreKind.GenServer do
  use GenServer

  @impl GenServer
  def init(data), do: {:ok, data}

  @impl GenServer
  def handle_call({:lookup, id}, _from, data), do: {:reply, data[id], data}
end
