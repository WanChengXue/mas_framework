defmodule ModelTest.Core.ActorState do
  alias __MODULE__

  @enfoce_keys [
    :receipt_box,
    :attr_map
  ]

  defstruct [:receipt_box, :attr_map]

  def new() do
    %ActorState{receipt_box: %{}, attr_map: %{}}
  end

  def set_state(%ActorState{} = actor_state, key, value) do
    updated_attr_map = Map.put(actor_state.attr_map, key, value)
    %ActorState{actor_state | attr_map: updated_attr_map}
  end

  def get_state(%ActorState{} = actor_state, key) do
    actor_state.attr_map[key]
  end

  def add_message_receipt(%ActorState{} = actor_state, message_id, receiver) do
    updated_receipt_box = Map.put(actor_state.receipt_box, message_id, receiver)
    %ActorState{actor_state | receipt_box: updated_receipt_box}
  end

  def get_message_receipt(%ActorState{} = actor_state, message_id) do
    actor_state.receipt_box[message_id]
  end
end
