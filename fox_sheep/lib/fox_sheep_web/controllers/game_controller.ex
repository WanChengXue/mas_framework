defmodule FoxSheepWeb.GameController do
  use FoxSheepWeb, :controller

  def get_game_scenario(conn, _params) do
    # The home page is often custom made,
    game_info = FoxSheep.Env.get_env_state()
    conn
    |> put_status(:ok)
    |> json(game_info)
  end

  def start_game(conn, %{"fox_number" => fox_number, "sheep_number" => sheep_nubmer}) do
    FoxSheep.SupervisorManager.start_game(
        {String.to_integer(fox_number), String.to_integer(sheep_nubmer)}
    )
    game_info = %{}
    conn
    |> put_status(:ok)
    |> json(game_info)
  end


  def stop_game(conn, _prams) do
    # 暂停游戏
  end

  def end_game(conn, _params) do
    # 结束游戏
  end
end
