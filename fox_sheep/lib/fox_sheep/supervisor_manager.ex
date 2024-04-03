defmodule FoxSheep.SupervisorManager do
    use GenServer
    def init(_) do
        {:ok, %{}}
    end


    def handle_cast({:start_game, {fox_number, sheep_number}}, state) do
        FoxSheep.EnvSupervisor.start_link({fox_number, sheep_number})
        FoxSheep.Env.live_loop()
        {:noreply, state}
    end


    def start_link(args) do
        GenServer.start_link(__MODULE__, args, name: :supervisor_manager)
    end

    def start_game({fox_number, sheep_number}) do
        GenServer.cast(:supervisor_manager, {:start_game, {fox_number, sheep_number}})
        # FoxSheep.Env.get_env_state()
    end
end
