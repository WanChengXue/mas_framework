defmodule ModelTest.Scenario.EnvState do
  # 定义实际场景中，环境状态有什么
  # 暂时设计为轮询的方式查找后端数据，需要一个列表存放数据
  alias __MODULE__

  @enfoce_keys [
    :stream_list,
    :agent_pid_map,
    :abstract_rule,
    :game_id
    :game_pid
    :abstract_env_pid
  ]

  defstruct [:stream_list, :agent_pid_map, :abstract_rule, :game_id, :game_pid, :abstract_env_pid]

  def new() do
    %EnvState{
      stream_list: [],
      agent_pid_map: %{},
      abstract_rule: abstract_link_rule(),
      game_id: "",
      game_pid: "",
      abstract_env_pid: ""
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

  def regist_actor(%EnvState{} = env_state, agent_name, agent_pid) do
    updated_agent_pid_map = Map.put(env_state.agent_pid_map, agent_name, agent_pid)
    %EnvState{env_state | agent_pid_map: updated_agent_pid_map}
  end

  def regist_env_pid(%EnvState{} = env_state, game_id, game_pid, abstract_game_pid) do
    env_state
    |> Map.put(game_id: game_id)
    |> Map.put(game_pid: game_pid)
    |> Map.put(abstract_game_pid: abstract_game_pid)
  end
end
