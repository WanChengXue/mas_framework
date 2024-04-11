defmodule ModelTest.Scenario.EnvState do
  # 定义实际场景中，环境状态有什么
  # 暂时设计为轮询的方式查找后端数据，需要一个列表存放数据
  alias __MODULE__

  @enfoce_keys [
    :stream_list,
    :actor_pid_map,
    :abstract_rule,
    :attr_map,
    :conversation_cache
  ]

  defstruct [:stream_list, :actor_pid_map, :abstract_rule, :attr_map, :conversation_cache]

  def new() do
    %EnvState{
      stream_list: [],
      actor_pid_map: %{},
      abstract_rule: abstract_link_rule(),
      attr_map: %{},
      conversation_cache: []
    }
  end

  def abstract_link_rule() do
    # 假设这个场景中一个question actor要链接上不超过4个answer actor，不超过1个critic actor
    # 一个answer actor最多链接3个question actor
    # 一个critic actor最多链接4个question actor
    # 双向链接，如果question actor发出链接请求到answer actor/critic actor，则被链接者的链接名额要-1
    %{
      "question_actor" => %{
        "answer_actor" => 4,
        "critic_actor" => 1
      },
      "answer_actor" => %{
        "question_actor" => 3
      },
      "critic_actor" => %{
        "question_actor" => 4
      }
    }
  end

  def regist_actor(%EnvState{} = env_state, actor_name, actor_pid) do
    updated_actor_pid_map = Map.put(env_state.actor_pid_map, actor_name, actor_pid)
    %EnvState{env_state | actor_pid_map: updated_actor_pid_map}
  end

  def get_actor(%EnvState{} = env_state, actor_name) do
    env_state.actor_pid_map[actor_name]
  end

  def set_state(%EnvState{} = env_state, key, value) do
    updated_attr_map = Map.put(env_state.attr_map, key, value)
    %EnvState{env_state | attr_map: updated_attr_map}
  end

  def get_state(%EnvState{} = env_state, key) do
    env_state.attr_map[key]
  end

  def append_conversation(%EnvState{} = env_state, actor_name, conversation) do
    current_conversation_cache =
      env_state.conversation_cache ++ ["#{actor_name}: #{conversation}"]
    %EnvState{env_state | conversation_cache: current_conversation_cache}
  end
end
