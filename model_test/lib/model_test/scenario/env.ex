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

    GenServer.cast(game_pid, {:register_actor, actor_name, actor_pid})
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

  # ----------- genserver related -------
  def init(_) do
    # 给这个环境创建一个数据结构用来存放结构性数据
    env_state = ModelTest.Scenario.EnvState.new()
    # 需要启动抽象环境
    {:ok, abs_env_pid} = ModelTest.Core.AbstractEnv.start_link([])
    # 假设启动了之后，暂时没有任何智能体存在, 将abs_env_pid放入到自己的状态中
    env_state = ModelTest.Scenario.EnvState.add_abstract_env_pid(env_state, abs_env_pid)
    {:ok, env_state}
  end

  def handle_call(:get_env_observation, _from, state) do
    {:reply, state |> Map.drop([:__struct__]), state}
  end

  def handle_cast({:register_actor, actor_name, actor_pid}, state) do
    new_state = ModelTest.Scenario.EnvState.register_actor(state, actor_name, actor_pid)
    {:noreply, new_state}
  end

  def handle_cast({:set_env_pid, env_id, env_pid, abstract_env_pid}, state) do
    new_state = ModelTest.Scenario.EnvState.regist_env_pid(env_id, env_pid, abstract_env_pid)
  end
end
