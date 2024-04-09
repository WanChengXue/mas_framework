defmodule ModelTest.Scenario.Env do
  #  --------- game controller --------
  use GenServer

  def start_link(arg) do
    {:ok, pid} = GenServer.start_link(__MODULE__, arg)
    game_id = Base.url_encode64(:crypto.strong_rand_bytes(16))
    {game_id, pid}
  end

  # ----------- more, about game logic part --------
  def get_env_observation(pid) do
    GenServer.call(pid, :get_env_observation)
  end

  def spawn_actor(actor_type, actor_name \\ "") do
    {actor_name, actor_pid} = 
        case actor_type do
            "question_actor" ->
                spawn_question_actor()
            "answer_actor" ->
                spawn_answer_actor()
            "critic_actor" ->
                spawn_critic_actor()
        end
    
  end

  def spawn_question_actor(actor_name) do
    {actor_name, actor_pid} = ModelTest.Scenario.question_actor().start_link(actor_name)
  end

  def spawn_answer_actor(actor_name) do
    {actor_name, actor_pid} = ModelTest.Scenario.answer_actor().start_link(actor_name)
  end

  def spawn_critic_actor(actor_name) do
    {actor_name, actor_pid} = ModelTest.Scenario.critic_actor().start_link(actor_name)
  end

  def detailed_graph() do
  end

  # ----------- genserver related -------
  def init(_) do
    # 给这个环境创建一个数据结构用来存放结构性数据
    env_state = ModelTest.Scenario.EnvState.new()
    # 需要启动抽象环境
    {:ok, abs_env_pid} = ModelTest.Core.AbstractEnv.start_link([])
    # 假设启动了之后，暂时没有任何智能体存在


    {:ok, env_state}
  end

  def handle_call(:get_env_observation, _from, state) do
    {:reply, state |> Map.drop([:__struct__]), state}
  end

  def handle_cast({:register_actor, actor_name, actor_pid}, state) do
    new_state = ModelTest.Scenario.EnvState.register_actor(state, actor_name, actor_pid)
    {:noreply, new_state}
  end
end
