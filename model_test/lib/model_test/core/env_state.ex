defmodule ModelTest.Core.EnvState do
  alias __MODULE__

  @enfoce_keys [
    :agent_number,
    :state,
    :agent_pid_map
  ]

  defstruct [:agent_number, :state, :agent_pid_map]

  def new(agent_number, state) do
    %EnvState{agent_number: agent_number, state: state, agent_pid_map: %{}}
  end

  def regist_actor(%EnvState{} = env_state, agent_name, agent_pid) do
    updated_agent_pid_map = Map.put(env_state.agent_pid_map, agent_name, agent_pid)
    %EnvState{env_state | agent_pid_map: updated_agent_pid_map}
  end
end
