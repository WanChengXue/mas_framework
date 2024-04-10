defmodule ModelTest.Core.AbstractEnv do
  use GenServer

  def init(_) do
    {:ok, ModelTest.Core.EnvState.new("mock_state")}
  end

  def handle_cast({:register_agent, agent_name, pid}, state) do
    new_state = ModelTest.Core.EnvState.regist_actor(state, agent_name, pid)
    {:noreply, new_state}
  end

  def handle_cast({:set_env_pid, env_pid}, state) do
    new_state = ModelTest.Core.EnvState.regist_env(state, env_pid)
    {:noreply, new_state}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def set_env_pid(pid, env_pid) do
    GenServer.cast(pid, {:set_env_pid, env_pid})
  end
end
