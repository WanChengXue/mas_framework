defmodule ModelTest.Core.AbstractEnv do
  use GenServer

  def init(_) do
    {:ok, ModelTest.Core.EnvState.new()}
  end

  def handle_cast({:register_actor, actor_name, pid}, state) do
    new_state = ModelTest.Core.EnvState.regist_actor(state, actor_name, pid)
    {:noreply, new_state}
  end

  def handle_cast({:set_env_pid, env_id, env_pid, pid}, state) do
    new_state =
      state
      |> ModelTest.Core.EnvState.set_state("env_id", env_id)
      |> ModelTest.Core.EnvState.set_state("env_pid", env_pid)
      |> ModelTest.Core.EnvState.set_state("abs_env_pid", pid)

    {:noreply, new_state}
  end

  def handle_cast({:regist_actor, actor_name, actor_pid}, state) do
    abs_actor_pid = GenServer.call(actor_pid, :abs_actor_pid)
    new_state = state |> ModelTest.Core.EnvState.regist_actor(actor_name, abs_actor_pid)
    {:noreply, new_state}
  end

  def handle_cast({:broadcast, actor_name, message}, state) do
    # 这个就是广播给所有的智能体 sender_pid, message_id, message
    actor_pid_map = ModelTest.Core.EnvState.get_actor_pid_map(state)
    sender_pid = actor_pid_map[actor_name]

    actor_pid_map
    |> Enum.each(fn {name, pid} ->
      if name != actor_name do
        GenServer.cast(pid, {:broadcast, sender_pid, message})
      end
    end)

    {:noreply, state}
  end

  def handle_call(:get_env_observation, _from, state) do
    {:reply, state |> Map.drop([:__struct__]), state}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def set_env_pid(pid, env_id, env_pid) do
    GenServer.cast(pid, {:set_env_pid, env_id, env_pid, pid})
  end

  def get_env_observation(pid) do
    GenServer.call(pid, :get_env_observation)
  end

  def regist_actor(pid, actor_name, actor_pid) do
    GenServer.cast(pid, {:regist_actor, actor_name, actor_pid})
  end
end
