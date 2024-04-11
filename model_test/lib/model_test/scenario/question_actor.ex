defmodule ModelTest.Scenario.QuestionActor do
  use GenServer

  def init(_) do
    # 定义智能体内部数据
    {:ok, pid} = ModelTest.Core.AbstractActor.start_link([])

    state =
      ModelTest.Scenario.QuestionActorState.new()
      |> ModelTest.Scenario.QuestionActorState.set_state("abs_actor_pid", pid)

    # 根据规则，需要随机寻找若干个answer actor进行回复，以及一个critic actor进行总结（抽象图）
    # %{"answer_actor" => answer_actor, "critic_actor" => critic_actor} = ModelTest.Scenario.Env.detailed_graph()
    {:ok, state}
    #
  end

  #   def handle_cast({:question, question}, state) do
  #     {:noreply, state}
  #   end

  def handle_call(:get_actor_state, _from, state) do
    abs_actor_pid = ModelTest.Scenario.QuestionActorState.get_state(state, "abs_actor_pid")
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
    abs_actor_pid = ModelTest.Scenario.QuestionActorState.get_state(state, "abs_actor_pid")

    new_state =
      state
      |> ModelTest.Scenario.QuestionActorState.set_state("actor_name", actor_name)
      |> ModelTest.Scenario.QuestionActorState.set_state("actor_pid", actor_pid)

    ModelTest.Core.AbstractActor.set_actor_pid(actor_name, actor_pid, abs_actor_pid)
    {:noreply, new_state}
  end

  def handle_cast({:set_attr, key, value}, state) do
    new_state = ModelTest.Scenario.QuestionActorState.set_state(state, key, value)
    {:noreply, new_state}
  end

  def handle_call(:abs_actor_pid, _from, state) do
    abs_actor_pid = ModelTest.Scenario.QuestionActorState.get_state(state, "abs_actor_pid")
    {:reply, abs_actor_pid, state}
  end

  # ---------- 具体场景的demo message ----------
  def handle_cast({:hi, message}, state) do
    # 为这个任务生成一个唯一的task id
    message_id = generate_message_id()
    env_pid = ModelTest.Scenario.QuestionActorState.get_state(state, "env_pid")
    # actor_name
    actor_name = ModelTest.Scenario.QuestionActorState.get_state(state, "actor_name")

    # 如果传入了一条消息，则这个智能体会发送给env，然后env再广播给所有的actor
    GenServer.cast(env_pid, {:broadcast, actor_name, {:ping, message_id, message}})
    {:noreply, state}
  end

  def handle_cast({:ping, message_id, content}, state) do
    # IO.inspect("broadcast message content is #{content}")
    abs_actor_pid = ModelTest.Scenario.QuestionActorState.get_state(state, "abs_actor_pid")
    GenServer.cast(abs_actor_pid, {:response, message_id, {:pong, "I can hear you!"}})
    {:noreply, state}
  end

  def handle_cast({:pong, content}, state) do
    IO.inspect(content)
    {:noreply, state}
  end

  # --------------- ping - pong broadcast demo -------

  # -------- set question --------
  def handle_cast({:set_question, content}, state) do
    # 设置了问题之后，这个question actor需要广播到环境中被其余智能体知晓
    message_id = generate_message_id()
    env_pid = ModelTest.Scenario.QuestionActorState.get_state(state, "env_pid")
    # actor_name
    actor_name = ModelTest.Scenario.QuestionActorState.get_state(state, "actor_name")

    new_state =
      ModelTest.Scenario.QuestionActorState.set_question_cache(state, message_id, content)
    GenServer.cast(env_pid, {:conversation_append, actor_name, content})
    GenServer.cast(env_pid, {:broadcast, actor_name, {:answer_question, message_id, content}})
    {:noreply, new_state}
  end

  def handle_cast({:question_reply, message_id, answer}, state) do
    IO.inspect(answer)
    new_state = ModelTest.Scenario.QuestionActorState.append_reply(state, message_id, answer)
    reply_length = ModelTest.Scenario.QuestionActorState.get_reply_length(new_state, message_id)

    if reply_length == 1 do
      env_pid = ModelTest.Scenario.QuestionActorState.get_state(new_state, "env_pid")
      actor_name = ModelTest.Scenario.QuestionActorState.get_state(new_state, "actor_name")

      {question, answer} =
        ModelTest.Scenario.QuestionActorState.get_reply_record(new_state, message_id)

      record_map = %{"question" => question, "answer" => answer}
      GenServer.cast(env_pid, {:broadcast, actor_name, {:critic_record, message_id, record_map}})
    end

    # 接受到了回复之后，发送给env智能体
    {:noreply, new_state}
  end

  def handle_cast({:critic_reply, critic_reply}, state) do
    IO.inspect(critic_reply)
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
  end

  def handle_cast(message, state) do
    {:noreply, state}
  end

  # ---------- tool function ---
  defp generate_message_id() do
    Base.url_encode64(:crypto.strong_rand_bytes(12))
  end

  # ---------- api --------
  def input_question(pid, question) do
    GenServer.cast(pid, {:set_question, question})
  end

  def get_actor_state(actor_pid) do
    GenServer.call(actor_pid, :get_actor_state)
  end
end
