defmodule ModelTest.Scenario.QuestionActor do
  use GenServer

  def init(_) do
    # 定义智能体内部数据
    {:ok, pid} = ModelTest.Core.AbstractActor.start_link([])
    # 根据规则，需要随机寻找若干个answer actor进行回复，以及一个critic actor进行总结（抽象图）
    # 获取环境
    # %{"answer_actor" => answer_actor, "critic_actor" => critic_actor} = ModelTest.Scenario.Env.detailed_graph()
    {:ok, %{"abstract_actor_pid" => pid}}
    # 
  end

  def handle_cast({:question, question}, state) do
    {:noreply, state}
  end

  def start_link(actor_name) do
    {:ok, pid} = GenServer.start_link(__MODULE__, actor_name)
    actor_name = case actor_name do
        "" -> Base.url_encode64(:crypto.strong_rand_bytes(16))
        _ -> actor_name
    end
    # 启动抽象智能体
    {actor_name, pid}
  end

  # ---------- api --------
  # def input_question(pid, question) do
  #     # 通过键入一条问题
end
