defmodule MnemonicsTest do
  alias Mnemonics.Example
  alias Mnemonics.Memory
  alias Mnemonics.Repo
  alias Mnemonics.Snap

  use ExUnit.Case

  doctest Mnemonics

  test "Lookup ETS." do
    assert [{1, %Example{id: 1, name: "1"}}] == :ets.lookup(Example.table_name(1), 1)
  end

  describe "load/1" do
    test "Load." do
      table_name = :examples_load_1
      Example.create_example_mnemonics(ExampleLoad1, table_name)
      :ok = ExampleLoad1.load(1)

      assert Enum.any?(
               Repo.tables(),
               &match?(%Memory{module: ExampleLoad1, table_name: ^table_name, version: 1}, &1)
             )

      assert [{1, %Example{id: 1, name: "1"}}] == :ets.lookup(ExampleLoad1.table_name(1), 1)
    end

    test "Reload." do
      table_name = :examples_load_2
      Example.create_example_mnemonics(ExampleLoad2, table_name)
      :ok = ExampleLoad2.load(1)
      table_name_1 = ExampleLoad2.table_name(1)
      :ok = ExampleLoad2.load(2)
      :ok = ExampleLoad2.load(3)

      refute Enum.any?(
               Repo.tables(),
               &match?(%Memory{module: ExampleLoad2, table_name: ^table_name, version: 1}, &1)
             )

      assert Enum.any?(
               Repo.tables(),
               &match?(%Memory{module: ExampleLoad2, table_name: ^table_name, version: 2}, &1)
             )

      assert Enum.any?(
               Repo.tables(),
               &match?(%Memory{module: ExampleLoad2, table_name: ^table_name, version: 3}, &1)
             )

      assert :undefined == :ets.info(table_name_1)
      refute table_name_1 in :ets.all()
      assert [{1, %Example{id: 1, name: "1"}}] == :ets.lookup(ExampleLoad2.table_name(2), 1)
      assert [{1, %Example{id: 1, name: "1"}}] == :ets.lookup(ExampleLoad2.table_name(3), 1)
    end

    test "Reload same version." do
      table_name = :examples_load_3
      Example.create_example_mnemonics(ExampleLoad3, table_name)
      :ok = ExampleLoad3.load(1)
      table_name_1_1 = ExampleLoad3.table_name(1)
      :ok = ExampleLoad3.load(1)
      table_name_1_2 = ExampleLoad3.table_name(1)
      refute table_name_1_1 == table_name_1_2

      assert Enum.any?(
               Repo.tables(),
               &match?(%Memory{module: ExampleLoad3, table_name: ^table_name, version: 1}, &1)
             )

      assert [{1, %Example{id: 1, name: "1"}}] == :ets.lookup(ExampleLoad3.table_name(1), 1)
    end
  end

  describe "snap/?" do
    test "Take a latest snapshot.",
      do:
        assert(
          %Snap{versions: %{examples: 1}, cache: %{examples: %{}}} == Example.snap(Snap.new())
        )

    test "Take a snapshot of the version.",
      do:
        assert(
          %Snap{versions: %{examples: 1}, cache: %{examples: %{}}} == Example.snap(Snap.new(), 1)
        )
  end

  describe "table/?" do
    test "Get the table." do
      assert %Memory{tid: table_name, module: Example, table_name: :examples, version: 1} =
               Example.table()

      refute :undefined == :ets.info(table_name)
    end

    test "Get the table & snapshot of the snapshot version." do
      snap = Snap.snap(Snap.new(), :examples, 1)

      assert %Memory{tid: table_name, module: Example, table_name: :examples, version: 1} =
               Example.table(snap)

      refute :undefined == :ets.info(table_name)
    end

    test "Get the table of the version." do
      assert %Memory{tid: table_name, module: Example, table_name: :examples, version: 1} =
               Example.table(1)

      refute :undefined == :ets.info(table_name)
    end
  end

  describe "table_name/?" do
    test "Get the table name.", do: refute(:undefined == :ets.info(Example.table_name()))

    test "Get the table name of the version.",
      do: refute(:undefined == :ets.info(Example.table_name(1)))
  end
end
