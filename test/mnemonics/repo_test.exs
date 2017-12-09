defmodule Mnemonics.RepoTest do
  alias Mnemonics.Example
  alias Mnemonics.Memory
  alias Mnemonics.Repo

  use ExUnit.Case

  doctest Repo

  describe "tables/0" do
    test "Get the list of tables." do
      assert Enum.any? Repo.tables, &match?({_, %Memory{table_name: :examples}}, &1)
    end
  end

  describe "handle_call(:call_memory)/3" do
    test "Write to memory" do
      table_name = :example_repo_call_message_1
      Example.create_example_mnemonics ExampleRepoCallMessage1, table_name
      :ok = ExampleRepoCallMessage1.load 1
      memory = ExampleRepoCallMessage1.table 1
      assert [] == :ets.lookup memory.tid, 3
      GenServer.call Repo, {
        :call_memory,
        memory,
        {:write, fn _ -> :ets.insert memory.tid, {3, %Example{id: 3, name: "3"}} end}
      }
      assert [{3, %Example{id: 3, name: "3"}}] == :ets.lookup memory.tid, 3
    end
  end
end
