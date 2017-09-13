{:ok, _} = Application.ensure_all_started :mnemonics
Application.put_env :mnemonics, :ets_dir, "test"
Mnemonics.Example.create_example_ets :examples
Mnemonics.Example.load 1
ExUnit.start
