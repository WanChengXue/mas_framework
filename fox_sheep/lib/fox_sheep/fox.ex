defmodule FoxSheep.Fox do
  use GenServer
  import YamlElixir
  require IEx

  def init(fox_name) do
    game_config = Path.join(File.cwd!(), "lib/fox_sheep/game_config.yaml")
    {:ok, game_params} = YamlElixir.read_from_file(game_config)
    # 随机初始化fox的位置
    world_length = game_params["common"]["world_length"]
    world_width = game_params["common"]["world_width"]
    fox_length = game_params["fox"]["length"]
    fox_width = game_params["fox"]["width"]
    location_x = generate_location(fox_length, world_length - fox_length)
    location_y = generate_location(fox_width, world_width - fox_width)

    location_map = %{
      "location_x" => location_x,
      "location_y" => location_y,
      "id" => fox_name,
      "stop_flag" => false
    }

    state = Map.merge(game_params["common"], game_params["fox"]) |> Map.merge(location_map)
    {:ok, state}
  end

  def handle_call({:act, observation}, _from, state) do
    # 策略部分
    # 观测，observation，定义数据格式为 [{location_x, location_y}]
    # 简单策略，如果说当前范围内有sheep，则判断出最近的sheep，采用追逐速度，如果追逐体力到了，就采用缓慢移动策略
    # 如果len(observation)不是0，则肯定有羊 
    if length(observation) == 0 do
      # 没看到羊，游荡
      direction = Enum.random(["Up", "Bottom", "Left", "Right"])
      speed = state["slow_speed_low"]
      {:reply, {direction, speed}, state}
    else
      # 看到了羊，先找到最近的那个
      fox_location_x = state["location_x"]
      fox_location_y = state["location_y"]

      {_closet_value, closet_index} =
        Enum.map(observation, fn {x, y} ->
          :math.sqrt((x - fox_location_x) ** 2 + (y - fox_location_y) ** 2)
        end)
        |> Enum.with_index()
        |> Enum.min_by(fn {value, index} -> value end)

      target_sheep = Enum.at(observation, closet_index)
      direction = {elem(target_sheep, 0) - fox_location_x, elem(target_sheep, 1) - fox_location_y}

      speed =
        state
        |> Map.get("rest_catch_time")
        |> case do
          time when time > 0 -> Map.get(state, "catch_speed")
          _ -> Map.get(state, "slow_speed_low")
        end

      {:reply, {direction, speed}, state}
    end
  end

  def handle_call(:get_location, _from, state) do
    location = [state["location_x"], state["location_y"]]
    {:reply, location, state}
  end

  def handle_cast(:live_loop, state) do
    new_state = Map.put(state, "stop_flag", false)
    Process.send_after(self(), :execute_live_loop, 10)
    {:noreply, new_state}
  end

  def handle_cast(:stop, state) do
    new_state = Map.put(state, "stop_flag", true)
    {:noreply, new_state}
  end

  def handle_info(:execute_live_loop, state) do
    # 每隔若干ms调用一次自己
    simulation_interval = ceil(1000 / state["simulation_rate"])

    case state["stop_flag"] do
      false ->
        live_loop(state)
        Process.send_after(self(), :execute_live_loop, simulation_interval)
        {:noreply, state}

      _ ->
        IO.inspect("game stop!")
        {:noreply, state}
    end
  end

  def live_loop(state) do
    IO.inspect("我是一只狼 #{state["id"]}")
  end

  defp generate_location(min_value, max_value) do
    :rand.uniform() * (max_value - min_value) + min_value
  end

  def continue_loop(pid) do
    GenServer.cast(pid, :live_loop)
  end

  def stop_loop(pid) do
    GenServer.cast(pid, :stop)
  end

  def start_loop(pid) do
    GenServer.cast(pid, :live_loop)
  end

  def get_location(pid) do
    GenServer.call(pid, :get_location)
  end

  def start_link([fox_name]) do
    IO.inspect("#{fox_name} start")
    GenServer.start_link(__MODULE__, fox_name, name: String.to_atom(fox_name))
  end
end

# __MODULE__.start_link(["fox_1"])
