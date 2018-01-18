defmodule Mnemonics.Example do
  use Mnemonics, table_name: :examples

  defstruct id: 0, name: "0"

  @spec create_example_ets(atom) :: any
  def create_example_ets(table_name) do
    fn ->
      table = :ets.new(table_name, [{:read_concurrency, true}])

      [
        %Mnemonics.Example{id: 1, name: "1"},
        %Mnemonics.Example{id: 2, name: "2"}
      ]
      |> Enum.each(&:ets.insert(table, {&1.id, &1}))

      :ok = :ets.tab2file(table, '/tmp/mnemonics/#{table_name}.ets')
      :ets.delete(table)
    end
    |> Task.async()
    |> Task.await()
  end

  @spec create_example_mnemonics(atom, atom) :: any
  def create_example_mnemonics(module_name, table_name) do
    create_example_ets(table_name)

    Code.eval_string("""
    defmodule #{module_name} do
      use Mnemonics, table_name: :#{table_name}
    end
    """)
  end
end
