defmodule Mnemonics.MemoryTest do
  alias Mnemonics.Example
  alias Mnemonics.Memory

  use ExUnit.Case

  doctest Memory

  describe "init/1" do
    test "Start an ETS." do
      Example.create_example_ets :examples_init_1
      assert {:ok, %Memory{module: Example, table_name: :examples_init_1, version: 1} = memory} =
        Memory.init module: Example, table_name: :examples_init_1, version: 1
      refute :undefined == :ets.info memory.tid
      assert memory.tid in :ets.all
    end
  end

  describe "handle_call(:stop)/3" do
    test "Stop the ETS." do
      Example.create_example_ets :examples_stop_1
      assert {:ok, %Memory{module: Example, table_name: :examples_stop_1, version: 1} = memory} =
        Memory.init module: Example, table_name: :examples_stop_1, version: 1
      refute :undefined == :ets.info memory.tid
      assert memory.tid in :ets.all
      Memory.handle_call :stop, self(), memory
      assert :undefined == :ets.info memory.tid
      refute memory.tid in :ets.all
    end
  end
end
