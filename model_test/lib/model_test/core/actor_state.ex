defmodule ModelTest.Core.ActorState do
    alias __MODULE__

    @enfoce_keys [
        :agent_number,
        :state,
        :agent_pid_map
    ]

    defstruct [:agent_number, :state, :agent_pid_map] 
end