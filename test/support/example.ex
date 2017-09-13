defmodule Mnemonics.Example do
  use Mnemonics, table_name: :examples

  defstruct id: 0, name: "0"

  @spec create_example_ets(atom) :: any
  def create_example_ets(table_name) do
    fn ->
      table = :ets.new table_name, [{:read_concurrency, true}]
      [
        %Mnemonics.Example{id: 1, name: "1"},
        %Mnemonics.Example{id: 2, name: "2"},
      ] |> Enum.each(&:ets.insert(table, {&1.id, &1}))
      :ok = :ets.tab2file table, 'test/#{table_name}.ets'
      :ets.delete table
    end
    |> Task.async
    |> Task.await
  end
end
