{:ok, _} = Application.ensure_all_started :mnemonics
Application.put_env :mnemonics, :ets_dir, "test"
fn ->
  table = :ets.new :examples, [:named_table, {:read_concurrency, true}]
  [
    %Mnemonics.Example{id: 1, name: "1"},
    %Mnemonics.Example{id: 2, name: "2"},
  ] |> Enum.each(&:ets.insert(table, {&1.id, &1}))
  :ok = :ets.tab2file table, 'test/examples.ets'
  :ets.delete :examples
end
|> Task.async
|> Task.await
Mnemonics.Example.load
ExUnit.start
