defmodule ModelTest.Scenario.AnswerActor do
  use GenServer

  def init(_) do
    # 此处是回答问题的actor的相关定义 
    {:ok, pid} = ModelTest.Core.AbstractActor.start_link([])
    state = ModelTest.Scenario.AnswerActorState.new() 
            |> ModelTest.Scenario.AnswerActorState.set_state("abs_actor_pid", pid) 
    {:ok, state}
  end

  def handle_call(:get_actor_state, _from, state) do
    abs_actor_pid = ModelTest.Scenario.AnswerActorState.get_state(state, "abs_actor_pid")
    abs_actor_state = ModelTest.Core.AbstractActor.get_actor_state(abs_actor_pid)
    {:reply, {state, abs_actor_state}, state}
  end


  def start_link(actor_name) do
    {:ok, pid} = GenServer.start_link(__MODULE__, actor_name)
    actor_name =
      case actor_name do
        "" -> Base.url_encode64(:crypto.strong_rand_bytes(16))
        _ -> actor_name
      end
    GenServer.cast(pid, {:set_actor_pid, actor_name, pid})
    {actor_name, pid}
  end

  def handle_cast({:set_actor_pid, actor_name, actor_pid}, state) do
    abstract_actor_pid = ModelTest.Scenario.AnswerActorState.get_state(state, "abs_actor_pid")

    new_state =
      state
      |> ModelTest.Scenario.AnswerActorState.set_state("actor_name", actor_name)
      |> ModelTest.Scenario.AnswerActorState.set_state("actor_pid", actor_pid)

    ModelTest.Core.AbstractActor.set_actor_pid(actor_name, actor_pid, abstract_actor_pid)
    {:noreply, new_state}
  end

  def handle_cast({:set_attr, key, value}, state) do
    new_state = ModelTest.Scenario.AnswerActorState.set_state(state, key, value)
    {:noreply, new_state}
  end

  def handle_call(:abs_actor_pid, _from, state) do
    abs_actor_pid = ModelTest.Scenario.AnswerActorState.get_state(state, "abs_actor_pid")
    {:reply, abs_actor_pid, state}
  end
  # --------- 以上都是模板代码 ----------

  # ----------- answer question ------------
  def handle_cast({:answer_question, message_id, content}, state) do
    abs_actor_pid = ModelTest.Scenario.QuestionActorState.get_state(state, "abs_actor_pid")
    # --------- 处理逻辑，按理来说此处最好是调用大模型解答，现在我随机生成一个文本（胡说八道） ----------
    waiting_text = ["你好啊", "你吃了没", "今天去哪里", "我想要放假", "我们去撸串", "太累了，睡觉", "你好宅", "气死我了"]
    answer = Enum.random(waiting_text)
    GenServer.cast(abs_actor_pid, {:response, message_id, {:question_reply, answer}})
    {:noreply, state}
  end


  # 模板代码，对core的继承
  def handle_cast({:broadcast, message}, state) do
    try do
        GenServer.cast(self(), message)
        {:noreply, state}
    catch
        _error -> {:noreply, state}
  end
  
  # ---------- tool function ---
  defp generate_message_id() do
    Base.url_encode64(:crypto.strong_rand_bytes(12))
  end

  # ---------- api -----------
  def get_actor_state(actor_pid) do
    GenServer.call(actor_pid, :get_actor_state)
  end
end
