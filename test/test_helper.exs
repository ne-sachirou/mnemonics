{:ok, _} = Application.ensure_all_started :mnemonics
File.mkdir_p! "/tmp/mnemonics"
Application.put_env :mnemonics, :ets_dir, "/tmp/mnemonics"
Mnemonics.Example.create_example_ets :examples
Mnemonics.Example.load 1
ExUnit.start
