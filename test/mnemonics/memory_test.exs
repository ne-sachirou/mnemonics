defmodule Mnemonics.MemoryTest do
  alias Mnemonics.Example
  alias Mnemonics.Memory

  use ExUnit.Case

  doctest Memory

  defp ets_dir, do: "/tmp/mnemonics"

  describe "init/1" do
    test "Start an ETS." do
      Example.create_example_ets(:examples_init_1)

      assert {:ok, %Memory{module: Example, table_name: :examples_init_1, version: 1} = memory} =
               Memory.init(
                 module: Example,
                 table_name: :examples_init_1,
                 version: 1,
                 ets_dir: ets_dir()
               )

      refute :undefined == :ets.info(memory.tid)
      assert memory.tid in :ets.all()
    end
  end

  describe "handle_call(:stop)/3" do
    test "Stop the ETS." do
      Example.create_example_ets(:examples_stop_1)

      assert {:ok, %Memory{module: Example, table_name: :examples_stop_1, version: 1} = memory} =
               Memory.init(
                 module: Example,
                 table_name: :examples_stop_1,
                 version: 1,
                 ets_dir: ets_dir()
               )

      refute :undefined == :ets.info(memory.tid)
      assert memory.tid in :ets.all()
      Memory.handle_call(:stop, self(), memory)
      assert :undefined == :ets.info(memory.tid)
      refute memory.tid in :ets.all()
    end
  end

  describe "handle_call(:write)/3" do
    test "Write request." do
      Example.create_example_ets(:examples_write_1)

      {:ok, memory} =
        Memory.init(
          module: Example,
          table_name: :examples_write_1,
          version: 1,
          ets_dir: ets_dir()
        )

      assert [] == :ets.lookup(memory.tid, 3)

      Memory.handle_call(
        {:write, fn memory -> :ets.insert(memory.tid, {3, %Example{id: 3, name: "3"}}) end},
        self(),
        memory
      )

      assert [{3, %Example{id: 3, name: "3"}}] == :ets.lookup(memory.tid, 3)
    end

    test "Raising an error doesn't crash." do
      Example.create_example_ets(:examples_write_2)

      {:ok, memory} =
        Memory.init(
          module: Example,
          table_name: :examples_write_2,
          version: 1,
          ets_dir: ets_dir()
        )

      assert {:reply, {:error, %RuntimeError{message: "Error test"}}, memory} ==
               Memory.handle_call({:write, fn _ -> raise "Error test" end}, self(), memory)
    end

    test "Write from outside." do
      Example.create_example_mnemonics(ExampleWrite3, :examples_write_3)
      ExampleWrite3.load(1)
      assert [] == :ets.lookup(ExampleWrite3.table_name(), 3)

      GenServer.call(
        ExampleWrite3.table().pid,
        {:write, fn memory -> :ets.insert(memory.tid, {3, %Example{id: 3, name: "3"}}) end}
      )

      assert [{3, %Example{id: 3, name: "3"}}] == :ets.lookup(ExampleWrite3.table_name(), 3)
    end
  end
end
