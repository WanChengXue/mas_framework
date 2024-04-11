defmodule ModelTest.Scenario.QuestionActorState do
  alias __MODULE__

  @enfoce_keys [
    :mail_box,
    :attr_map
  ]

  defstruct [:mail_box, :attr_map]

  def new() do
    %QuestionActorState{mail_box: MapSet.new(), attr_map: %{}}
  end

  def set_state(%QuestionActorState{} = actor_state, key, value) do
    updated_attr_map = Map.put(actor_state.attr_map, key, value)
    %QuestionActorState{actor_state | attr_map: updated_attr_map}
  end

  def get_state(%QuestionActorState{} = actor_state, key) do
    actor_state.attr_map[key]
  end
end
