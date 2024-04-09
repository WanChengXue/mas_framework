defmodule ModelTestWeb.GameController do
  use ModelTestWeb, :controller

  def game_home(conn, _params) do
    # 游戏主界面，返回的是三个按钮，new, exit, load
    conn
    |> put_status(:ok)
    |> json(%{"operation" => ["new", "load", "exit"]})
  end

  def new_game(conn, _params) do
    # 创建一个新的游戏实例，通过cacher进行创建
    {game_id, game_pid} = ModelTest.GameCacher.new_game()
    # 获取game的state数据返回给前端进行渲染
    game_data =
      ModelTest.Scenario.Env.get_env_observation(game_pid) |> Map.put("game_id", game_id)

    IO.inspect(game_data)

    conn
    |> put_status(:ok)
    |> json(game_data)
  end

  def get_game_observation(conn, %{"game_id" => game_id}) do
    # 从cacher中查找指定game_id对应的pid
    game_pid = ModelTest.GameCacher.get_game_pid(game_id)
    # 获取指定环境的观测状态
    game_data = ModelTest.Scenario.Env.get_env_observation(game_pid)

    conn
    |> put_status(:ok)
    |> json(game_data)
  end

  def new_actor(conn, %{"game_id"=>game_id, "actor_type"=>actor_type, "actor_name" => actor_name}) do
    game_pid = ModelTest.GameCacher.get_game_pid(game_id)
    ModelTest.Scenario.Env.spawn_actor(actor_type, actor_name)
    conn |> put_status(:ok)
  end

  def question(conn, %{"game_id" => game_id, "actor_name" => actor_name, "question" => question}) do
    game_pid = ModelTest.GameCacher.get_game_pid(game_id)
    actor_pid = ModelTest.Scenario.Env.get_actor_pid(game_pid, actor_name)
    ModelTest.Scenario.QuestionActor.question(actor_pid, question)
    conn |> put_status(:ok)
  end


  # ------- 不是重要api，暂时不开发 ------
  def stop_game() do
  end

  def end_game() do
  end

  def save_game() do
  end

  def load_game() do
  end

  def reset_game() do
  end
end
