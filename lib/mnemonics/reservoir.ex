defmodule Mnemonics.Reservoir.CompileHook do
  @moduledoc false

  defmacro __before_compile__(_env) do
    if Version.match?(System.version(), ">= 1.6.0") do
      quote do
        use DynamicSupervisor

        alias Mnemonics.Memory

        @doc false
        @spec start_link(keyword) :: Supervisor.on_start()
        def start_link(arg), do: DynamicSupervisor.start_link(__MODULE__, arg, name: arg[:name])

        @doc false
        def init(_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

        @doc """
        Helper function to start DynamicSupervisor child for both Elixir 1.5 & 1.6.
        """
        @spec start_child(Memory.init_args()) :: Supervisor.on_start_child()
        def start_child(arg) do
          {sup_name, arg} = pop_in(arg[:sup_name])
          DynamicSupervisor.start_child(Module.concat(sup_name, Reservoir), {Memory, arg})
        end
      end
    else
      quote do
        use Supervisor

        alias Mnemonics.Memory

        @doc false
        @spec start_link(keyword) :: Supervisor.on_start()
        def start_link(arg), do: Supervisor.start_link(__MODULE__, arg, name: arg[:name])

        @doc false
        @spec init([term]) :: {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}}
        def init(_arg), do: Supervisor.init([{Memory, []}], strategy: :simple_one_for_one)

        @doc """
        Helper function to start DynamicSupervisor child for both Elixir 1.5 & 1.6.
        """
        @spec start_child(Memory.init_args()) :: Supervisor.on_start_child()
        def start_child(arg) do
          {sup_name, arg} = pop_in(arg[:sup_name])
          Supervisor.start_child(Module.concat(sup_name, Reservoir), [arg])
        end
      end
    end
  end
end

defmodule Mnemonics.Reservoir do
  @moduledoc """
  Supervise `Mnemonics.Memory`.
  """

  @before_compile __MODULE__.CompileHook
end
