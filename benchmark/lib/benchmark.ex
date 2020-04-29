defmodule Benchmark do
  @moduledoc """
  """

  @doc """
  """
  def run do
    for test_case <- [Benchmark.Cases.DataStoreKind] do
      IO.inspect(test_case)
      test_case.run
    end
  end
end
