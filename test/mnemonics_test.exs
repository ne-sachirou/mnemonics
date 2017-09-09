defmodule MnemonicsTest do
  use ExUnit.Case

  alias Mnemonics.Example

  doctest Mnemonics

  test "Lookup ETS." do
    assert [{1, %Example{id: 1, name: "1"}}] == :ets.lookup Example.table_name, 1
  end

  describe "table_name/0" do
    test "Get the table name." do
      assert :examples == Example.table_name
    end
  end
end
