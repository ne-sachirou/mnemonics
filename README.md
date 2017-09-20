Mnemonics
==
Read only data store for Elixir: fast, concurrently, for large data & hot reloadable.

[![Hex.pm](https://img.shields.io/hexpm/v/mnemonics.svg)](https://hex.pm/packages/mnemonics)
[![Build Status](https://travis-ci.org/ne-sachirou/mnemonics.svg?branch=master)](https://travis-ci.org/ne-sachirou/mnemonics)

Mnemonics is analogous to Ruby's [ActiveHash](https://github.com/zilkey/active_hash) in it's usecase.

[Document](https://hex.pm/docs/mnemonics).

Installation
--
Add `mnemonics` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mnemonics, "~> 0.1"}
  ]
end
```

Usage
--
Config Mnemonics ets_dir. `config.exs`:

```elixir
config :mnemonics, :ets_dir, "priv/seeds"
```

Create an `example.ets` by `:ets.tab2file/3`. Then put it into the ets_dir. The `examples.ets` stores `{:example1, %{id: :example1}}`.

```
priv/
└seeds/
  └examples.ets
```

Create an `Example` module, use Mnemonics & load.

```elixir
defmodule Example do
  use Mnemonics, table_name: :examples
end

Example.load 1
```

We can lookup the table.

```elixir
:ets.lookup Example.table_name(1), :example1
```

Let's reload a new table. Put a new `examples.ets` into the ets_dir & load it with a new version number.

```elixir
Example.load 2
```

We can lookup the new table.

```elixir
:ets.lookup Example.table_name(2), :example1
```

### :ets.new/2 Option
* Should `:public` or `:protected`. `:protected` (default) is recommended.
* Can't `:named_table`.
* `{:read_concurrency, true}` is recommended.

## Architechture
[![processes](./processes.png)](https://github.com/ne-sachirou/mnemonics/blob/master/processes.png)
