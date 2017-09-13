defmodule Mnemonics.MemoryTest do
  alias Mnemonics.Example
  alias Mnemonics.Memory

  use ExUnit.Case

  doctest Memory

  describe "init/1" do
    test "Start an ETS." do
      Example.create_example_ets :examples_init_1
      Memory.init table_name: :examples_init_1, version: 1
      assert :"examples_init_1:1" in :ets.all
    end
  end

  describe "handle_call(:stop)/3" do
    test "Stop the ETS." do
      Example.create_example_ets :examples_stop_1
      Memory.init table_name: :examples_stop_1, version: 1
      assert :"examples_stop_1:1" in :ets.all
      Memory.handle_call :stop, self(), %Memory{table_name: :examples_stop_1, version: 1}
      refute :"examples_stop_1:1" in :ets.all
    end
  end
end
