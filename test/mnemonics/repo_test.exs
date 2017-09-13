defmodule Mnemonics.RepoTest do
  alias Mnemonics.Repo

  use ExUnit.Case

  doctest Repo

  describe "handle_call(:tables)/3" do
    test "Get the list of tables." do
      assert Enum.any? GenServer.call(Repo, :tables), &match?({:examples, 1, _}, &1)
    end
  end
end
