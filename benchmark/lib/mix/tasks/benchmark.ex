defmodule Mix.Tasks.Benchmark do
  @moduledoc """
  Run bemchmarks.
  """

  use Mix.Task

  @shortdoc "Run bemchmarks."

  @impl Mix.Task
  def run(_), do: Benchmark.run()
end
