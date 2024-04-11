defmodule ModelTest.Scenario.Env do
  #  --------- game controller --------
  use GenServer

  def start_link(arg) do
    {:ok, pid} = GenServer.start_link(__MODULE__, arg)
    game_id = Base.url_encode64(:crypto.strong_rand_bytes(16))
    GenServer.cast(pid, {:set_env_pid, game_id, pid})
    {game_id, pid}
  end

  # ----------- more, about game logic part --------
  def get_env_observation(pid) do
    GenServer.call(pid, :get_env_observation)
  end

  def get_env_state(pid) do
    GenServer.call(pid, :get_env_state)
  end

  def get_actor_pid(pid, actor_name) do
    GenServer.call(pid, {:get_actor_pid, actor_name})
  end

  def spawn_actor(game_pid, actor_type, actor_name \\ "") do
    {actor_name, actor_pid} =
      case actor_type do
        "question_actor" ->
          spawn_question_actor(actor_name)

        "answer_actor" ->
          spawn_answer_actor(actor_name)

        "critic_actor" ->
          spawn_critic_actor(actor_name)
      end

    GenServer.cast(game_pid, {:regist_actor, actor_name, actor_pid})
    # 将game id发送过去
    GenServer.cast(actor_pid, {:set_attr, "env_pid", game_pid})
    actor_name
  end

  def spawn_question_actor(actor_name) do
    {actor_name, actor_pid} = ModelTest.Scenario.QuestionActor.start_link(actor_name)
  end

  def spawn_answer_actor(actor_name) do
    {actor_name, actor_pid} = ModelTest.Scenario.AnswerActor.start_link(actor_name)
  end

  def spawn_critic_actor(actor_name) do
    {actor_name, actor_pid} = ModelTest.Scenario.CriticActor.start_link(actor_name)
  end

  def detailed_graph() do
  end

  def get_actor_state(pid, actor_name) do
    GenServer.call(pid, {:get_actor_state, actor_name})
  end

  # ----------- genserver related -------
  def init(_) do
    # 给这个环境创建一个数据结构用来存放结构性数据
    env_state = ModelTest.Scenario.EnvState.new()
    # 需要启动抽象环境
    {:ok, abs_env_pid} = ModelTest.Core.AbstractEnv.start_link([])

    # 假设启动了之后，暂时没有任何智能体存在, 将abs_env_pid放入到自己的状态中
    env_state = ModelTest.Scenario.EnvState.set_state(env_state, "abs_env_pid", abs_env_pid)
    {:ok, env_state}
  end

  def handle_call(:get_env_observation, _from, state) do
    {:reply, %{"conversation_cache" => state.conversation_cache}, state}
  end

  def handle_call(:get_env_state, _from, state) do
    abs_env_pid = ModelTest.Scenario.EnvState.get_state(state, "abs_env_pid")
    abs_env_state = ModelTest.Core.AbstractEnv.get_env_observation(abs_env_pid)
    {:reply, {state, abs_env_state}, state}
  end

  def handle_call({:get_actor_pid, actor_name}, _from, state) do
    actor_pid = ModelTest.Scenario.EnvState.get_actor(state, actor_name)
    {:reply, actor_pid, state}
  end

  def handle_call({:get_actor_state, actor_name}, _from, state) do
    actor_pid = ModelTest.Scenario.EnvState.get_actor(state, actor_name)
    actor_state = GenServer.call(actor_pid, :get_actor_state)
    {:reply, actor_state, state}
  end

  def handle_cast({:regist_actor, actor_name, actor_pid}, state) do
    new_state = ModelTest.Scenario.EnvState.regist_actor(state, actor_name, actor_pid)
    abs_env_pid = ModelTest.Scenario.EnvState.get_state(state, "abs_env_pid")
    ModelTest.Core.AbstractEnv.regist_actor(abs_env_pid, actor_name, actor_pid)
    {:noreply, new_state}
  end

  def handle_cast({:set_env_pid, env_id, env_pid}, state) do
    new_state =
      state
      |> ModelTest.Scenario.EnvState.set_state("env_id", env_id)
      |> ModelTest.Scenario.EnvState.set_state("env_pid", env_pid)

    # 给abstract env添加三个变量
    abstract_env_pid = ModelTest.Scenario.EnvState.get_state(state, "abs_env_pid")
    ModelTest.Core.AbstractEnv.set_env_pid(abstract_env_pid, env_id, env_pid)
    {:noreply, new_state}
  end

  def handle_cast({:broadcast, actor_name, message}, state) do
    abs_env_pid = ModelTest.Scenario.EnvState.get_state(state, "abs_env_pid")
    GenServer.cast(abs_env_pid, {:broadcast, actor_name, message})
    {:noreply, state}
  end

  def handle_cast({:conversation_append, actor_name, conversation}, state) do
    new_state = ModelTest.Scenario.EnvState.append_conversation(state, actor_name, conversation)
    {:noreply, new_state}
  end
end

# {id, env_pid} = ModelTest.GameCacher.new_game()
# ModelTest.Scenario.Env.spawn_actor(env_pid, "question_actor", "test")
# ModelTest.Scenario.Env.spawn_actor(env_pid, "answer_actor", "test2")
# ModelTest.Scenario.Env.spawn_actor(env_pid, "critic_actor", "test3")
# {a,b} = ModelTest.Scenario.Env.get_actor_state(env_pid, "test")
# actor_pid = a.attr_map["actor_pid"]
# ModelTest.Scenario.Env.get_env_state(env_pid)
# GenServer.cast(actor_pid, {:set_question, "hello"})
