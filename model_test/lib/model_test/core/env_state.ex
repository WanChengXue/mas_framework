defmodule ModelTest.Core.EnvState do
  alias __MODULE__

  @enfoce_keys [
    :actor_number,
    :attr_map,
    :actor_pid_map
  ]

  defstruct [:actor_number, :attr_map, :actor_pid_map]

  def new(state \\ %{}) do
    %EnvState{
      actor_number: 0,
      attr_map: state,
      actor_pid_map: %{}
    }
  end

  def regist_actor(%EnvState{} = env_state, actor_name, actor_pid) do
    updated_actor_pid_map = Map.put(env_state.actor_pid_map, actor_name, actor_pid)
    %EnvState{env_state | actor_pid_map: updated_actor_pid_map}
  end

  def get_actor_pid_map(%EnvState{} = env_state) do
    env_state.actor_pid_map
  end

  def set_state(%EnvState{} = env_state, key, value) do
    updated_attr_map = Map.put(env_state.attr_map, key, value)
    %EnvState{env_state | attr_map: updated_attr_map}
  end

  def get_state(%EnvState{} = env_state, key) do
    env_state.attr_map[key]
  end
end
