alias Mix.Tasks.Server

require Logger

defmodule Mix.Tasks.Server.PostgresWorker do
  @moduledoc false

  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, [])

  def init(_) do
    GenServer.cast(self(), :run)
    {:ok, nil}
  end

  def handle_cast(:run, state) do
    Task.start_link(fn ->
      System.cmd("docker-compose", ["up"], into: IO.stream(:stdio, :line))
    end)

    {:noreply, state}
  end

  # def terminate(_, _), do: System.cmd("docker-compose", ["down"], into: IO.stream(:stdio, :line))
end

defmodule Mix.Tasks.Server.PhoenixWorker do
  @moduledoc false

  use Task

  def start_link(_), do: Task.start_link(__MODULE__, :run, [])

  def run do
    wait_to_start_postgres()
    Mix.Task.run("ecto.create")
    Mix.Task.run("ecto.migrate")
    Mix.Task.run("phx.server")
  end

  defp wait_to_start_postgres do
    result =
      System.cmd("docker-compose", [
        "exec",
        "postgres",
        "psql",
        "-U",
        "postgres",
        "-c",
        "select 1"
      ])

    case result do
      {_, 0} ->
        :ok

      error ->
        Logger.info(inspect(error))
        Process.sleep(1000)
        wait_to_start_postgres()
    end

    # with {:ok, socket} <- :gen_tcp.connect('localhost', 5432, [:binary, {:packet, :raw}]),
    #      {:ok, _} <-
    #        Postgrex.Protocol.ping(%Postgrex.Protocol{
    #          sock: {:gen_tcp, socket},
    #          buffer: :active_once,
    #          timeout: 1000
    #        }) do
    #   :ok = :gen_tcp.close(socket)
    # else
    #   error ->
    #     Logger.info(inspect(error))
    #     Process.sleep(1000)
    #     wait_to_start_postgres()
    # end
  end
end

defmodule Mix.Tasks.Server.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link do
    children = [
      {Server.PostgresWorker, []},
      {Server.PhoenixWorker, []}
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end

defmodule Mix.Tasks.Server do
  @moduledoc """
  Start app stack.

  `mix do compile, server && docker-compose down`
  """

  require Logger

  use Mix.Task

  @shortdoc "Start app stack"

  @spec run([String.t()]) :: any
  def run(_args) do
    {:ok, pid} = Server.Supervisor.start_link()
    Process.flag(:trap_exit, true)

    receive do
      {:EXIT, _, _} = message ->
        Logger.info(inspect(message))
        Supervisor.stop(pid)
    end

    # receive(do: (_ -> nil))
  end
end
