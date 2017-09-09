defmodule Mnemonics.RepoTest do
  use ExUnit.Case

  doctest Mnemonics

  describe "handle_call(:tables)/3" do
    test "Get the list of tables." do
      assert %{examples: _} = GenServer.call Mnemonics.Repo, :tables
    end
  end
end
