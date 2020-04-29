defmodule BenchmarkTest do
  use ExUnit.Case
  doctest Benchmark

  test "greets the world" do
    assert Benchmark.hello() == :world
  end
end
