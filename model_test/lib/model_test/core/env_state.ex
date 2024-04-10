defmodule ModelTest.Core.EnvState do
  alias __MODULE__

  @enfoce_keys [
    :agent_number,
    :state,
    :agent_pid_map,
    :abstract_env_pid,
    :env_pid
  ]

  defstruct [:agent_number, :state, :agent_pid_map, :abstract_env_pid, :env_pid]

  def new(state) do
    %EnvState{
      agent_number: 0,
      state: state,
      agent_pid_map: %{},
      abstract_env_pid: "",
      env_pid: ""
    }
  end

  def regist_actor(%EnvState{} = env_state, agent_name, agent_pid) do
    updated_agent_pid_map = Map.put(env_state.agent_pid_map, agent_name, agent_pid)
    %EnvState{env_state | agent_pid_map: updated_agent_pid_map}
  end

  def add_abstract_env_pid(env_state, abs_env_pid) do
    %EnvState{env_state | abstract_env_pid: abs_env_pid}
  end

  def set_env_pid(env_state, env_pid) do
    %EnvState{env_state | env_pid: env_pid}
  end
end
