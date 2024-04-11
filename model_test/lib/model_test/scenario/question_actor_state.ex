defmodule ModelTest.Scenario.QuestionActorState do
  alias __MODULE__

  @enfoce_keys [
    :mail_box,
    :attr_map,
    :question_cache_box
  ]

  defstruct [:mail_box, :attr_map, :question_cache_box]

  def new() do
    %QuestionActorState{mail_box: MapSet.new(), attr_map: %{}, question_cache_box: %{}}
  end

  def set_state(%QuestionActorState{} = actor_state, key, value) do
    updated_attr_map = Map.put(actor_state.attr_map, key, value)
    %QuestionActorState{actor_state | attr_map: updated_attr_map}
  end

  def get_state(%QuestionActorState{} = actor_state, key) do
    actor_state.attr_map[key]
  end

  def set_question_cache(%QuestionActorState{} = actor_state, message_id, question) do
    updated_question_cache_box =
      Map.put(actor_state.question_cache_box, message_id, {question, []})

    %QuestionActorState{actor_state | question_cache_box: updated_question_cache_box}
  end

  def append_reply(%QuestionActorState{} = actor_state, message_id, question_reply) do
    {question, current_reply_list} = actor_state.question_cache_box[message_id]
    updated_reply_list = current_reply_list ++ [question_reply]

    updated_question_cache_box =
      Map.put(actor_state.question_cache_box, message_id, {question, updated_reply_list})

    %QuestionActorState{actor_state | question_cache_box: updated_question_cache_box}
  end

  def get_reply_length(%QuestionActorState{} = actor_state, message_id) do
    {question, current_reply_list} = actor_state.question_cache_box[message_id]
    length(current_reply_list)
  end

  def get_reply_record(%QuestionActorState{} = actor_state, message_id) do
    actor_state.question_cache_box[message_id]
  end
end
