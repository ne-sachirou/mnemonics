defmodule Mnemonics.RepoTest do
  alias Mnemonics.Memory
  alias Mnemonics.Repo

  use ExUnit.Case

  doctest Repo

  describe "handle_call(:tables)/3" do
    test "Get the list of tables." do
      assert Enum.any? GenServer.call(Repo, :tables), &match?({_, %Memory{table_name: :examples}}, &1)
    end
  end
end
