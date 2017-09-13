defmodule MnemonicsTest do
  alias Mnemonics.Example
  alias Mnemonics.Repo

  use ExUnit.Case

  doctest Mnemonics

  test "Lookup ETS." do
    assert [{1, %Example{id: 1, name: "1"}}] == :ets.lookup Example.table_name(1), 1
  end

  describe "load/1" do
    test "Load." do
      table_name = :examples_load_1
      Example.create_example_ets table_name
      Code.eval_string """
        defmodule ExampleLoad1 do
          use Mnemonics, table_name: :#{table_name}
        end
      """
      :ok = ExampleLoad1.load 1
      assert Enum.any? GenServer.call(Repo, :tables), &match?({^table_name, 1, _}, &1)
      assert [{1, %Example{id: 1, name: "1"}}] == :ets.lookup ExampleLoad1.table_name(1), 1
    end

    test "Reload." do
      table_name = :examples_load_2
      Example.create_example_ets table_name
      Code.eval_string """
        defmodule ExampleLoad2 do
          use Mnemonics, table_name: :#{table_name}
        end
      """
      :ok = ExampleLoad2.load 1
      :ok = ExampleLoad2.load 2
      :ok = ExampleLoad2.load 3
      refute Enum.any? GenServer.call(Repo, :tables), &match?({^table_name, 1, _}, &1)
      assert Enum.any? GenServer.call(Repo, :tables), &match?({^table_name, 2, _}, &1)
      assert Enum.any? GenServer.call(Repo, :tables), &match?({^table_name, 3, _}, &1)
      # assert :undifined == :ets.info ExampleLoad2.table_name(1)
      # refute ExampleLoad2.table_name(1) in :ets.all
      assert [{1, %Example{id: 1, name: "1"}}] == :ets.lookup ExampleLoad2.table_name(2), 1
      assert [{1, %Example{id: 1, name: "1"}}] == :ets.lookup ExampleLoad2.table_name(3), 1
    end

    # test "Reload same version." do
    #   table_name = :examples_load_3
    #   Example.create_example_ets table_name
    #   Code.eval_string """
    #     defmodule ExampleLoad3 do
    #       use Mnemonics, table_name: :#{table_name}
    #     end
    #   """
    #   :ok = ExampleLoad3.load 1
    #   :ok = ExampleLoad3.load 1
    #   assert Enum.any? GenServer.call(Repo, :tables), &match?({^table_name, 1, _}, &1)
    #   assert [{1, %Example{id: 1, name: "1"}}] == :ets.lookup ExampleLoad3.table_name(1), 1
    # end
  end

  describe "table_name/0" do
    test "Get the table name." do
      assert :"examples:1" == Example.table_name
    end

    test "Get the table name of the version." do
      assert :"examples:1" == Example.table_name 1
    end
  end
end
