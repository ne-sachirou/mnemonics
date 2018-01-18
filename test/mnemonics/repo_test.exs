defmodule Mnemonics.RepoTest do
  alias Mnemonics.Memory
  alias Mnemonics.Repo

  use ExUnit.Case

  doctest Repo

  describe "tables/0" do
    test "Get the list of tables." do
      assert Enum.any?(Repo.tables(), &match?(%Memory{table_name: :examples}, &1))
    end
  end
end
