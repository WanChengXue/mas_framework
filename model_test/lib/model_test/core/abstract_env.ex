defmodule ModelTest.Core.AbstractEnv do
  use GenServer

  def init(_) do
    {:ok, ModelTest.Core.EnvState.new(0, "mock_state")}
  end

  def handle_cast({:register_agent, agent_name, pid}, state) do
    new_state = ModelTest.Core.EnvState.regist_actor(state, agent_name, pid)
    {:noreply, new_state}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  # api 
end
