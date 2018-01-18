defmodule Mnemonics.SnapTest do
  alias Mnemonics.Snap

  use ExUnit.Case

  doctest Snap

  defp build_snap,
    do: Snap.new() |> Snap.snap(:examples, 1) |> put_in([:examples, :cache, 1], "example 1")

  describe "snap/4" do
    test "Snap with non-default cache" do
      assert %{} == Snap.snap(Snap.new(), :examples, 1)[:examples].cache
      assert [] == Snap.snap(Snap.new(), :examples, 1, [])[:examples].cache
    end
  end

  describe "get/3" do
    test "get" do
      assert %{version: 1, cache: %{1 => "example 1"}} == Snap.get(build_snap(), :examples, nil)
      assert is_nil(Snap.get(build_snap(), :another, nil))
    end
  end

  describe "Kernel.get_in/2" do
    test "get_in function" do
      assert 1 == get_in(build_snap(), [:examples, :version])
      assert "example 1" == get_in(build_snap(), [:examples, :cache, 1])
    end

    test "Lookup syntax" do
      assert 1 == build_snap()[:examples].version
      assert "example 1" == build_snap()[:examples].cache[1]
    end

    test "Is nil for unknown table name", do: assert(is_nil(build_snap()[:another]))
  end

  describe "Kernel.get_and_update_in/3" do
    test "Update version" do
      assert {1, snap} = get_and_update_in(build_snap()[:examples].version, &{&1, &1 + 1})
      assert 2 == snap[:examples].version
    end

    test "Update cache" do
      assert {"example 1", snap} =
               get_and_update_in(build_snap()[:examples].cache[1], fn value ->
                 value = value || "example 1"
                 {value, value}
               end)

      assert "example 1" == snap[:examples].cache[1]

      assert {"example 1", snap} =
               get_and_update_in(build_snap()[:examples].cache[1], fn value ->
                 value = value || "example 11"
                 {value, value}
               end)

      assert "example 1" == snap[:examples].cache[1]
    end
  end

  describe "Kernel.pop_in/2" do
    test "pop_in function" do
      assert {%{version: 1, cache: %{1 => "example 1"}}, Snap.new()} ==
               pop_in(build_snap(), [:examples])

      assert {"example 1", snap} = pop_in(build_snap(), [:examples, :cache, 1])
      assert %{} == snap[:examples].cache
    end
  end

  describe "Kernel.put_in/3" do
    test "function syntax" do
      snap = put_in(build_snap(), [:examples, :version], 2)
      assert 2 == snap[:examples].version
      snap = put_in(build_snap(), [:examples, :cache, 1], "example 11")
      assert "example 11" == snap[:examples].cache[1]
    end

    test "macro syntax" do
      snap = put_in(build_snap()[:examples].version, 2)
      assert 2 == snap[:examples].version
      snap = put_in(build_snap()[:examples].cache[1], "example 11")
      assert "example 11" == snap[:examples].cache[1]
    end

    test "put_in a new snap" do
      snap = put_in(build_snap()[:another], %{version: 1, cache: %{}})
      assert 1 == snap[:another].version
      assert %{} == snap[:another].cache
      snap = put_in(build_snap()[:another], %{version: 1})
      assert 1 == snap[:another].version
      assert %{} == snap[:another].cache
      snap = put_in(build_snap()[:another], %{})
      assert 1 == snap[:another].version
      assert %{} == snap[:another].cache
    end
  end

  describe "Kernel.update_in/3" do
    test "function syntax" do
      snap = update_in(build_snap(), [:examples, :version], &(&1 + 1))
      assert 2 == snap[:examples].version
      snap = update_in(build_snap(), [:examples, :cache, 1], &(&1 <> "1"))
      assert "example 11" == snap[:examples].cache[1]
    end

    test "macro syntax" do
      snap = update_in(build_snap()[:examples].version, &(&1 + 1))
      assert 2 == snap[:examples].version
      snap = update_in(build_snap()[:examples].cache[1], &(&1 <> "1"))
      assert "example 11" == snap[:examples].cache[1]
    end
  end
end
