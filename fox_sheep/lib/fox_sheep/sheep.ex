defmodule FoxSheep.Sheep do
  use GenServer
  import YamlElixir
#   require IEx
  def init(sheep_name) do
    game_config = Path.join(File.cwd!(), "lib/fox_sheep/game_config.yaml")
    {:ok, game_params} = YamlElixir.read_from_file(game_config)
    # 随机初始化fox的位置
    world_length = game_params["common"]["world_length"]
    world_width = game_params["common"]["world_width"]
    sheep_length = game_params["sheep"]["length"]
    sheep_width = game_params["sheep"]["width"]
    location_x = generate_random_value(sheep_length, world_length - sheep_length)
    location_y = generate_random_value(sheep_width, world_width - sheep_width)
    # 脑袋的朝向
    {direction_x, direction_y} = generate_direction()
    external_map = %{
      "location_x" => location_x,
      "location_y" => location_y,
      "direction_x" => direction_x,
      "direction_y" => direction_y,
      "id" => sheep_name,
      "life" => game_params["sheep"]["life"],
      "stop_flag" => false,
      "last_recover_time" => System.system_time(:second)
    }

    state = Map.merge(game_params["common"], game_params["sheep"]) |> Map.merge(external_map)
    {:ok, state}
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


  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  def handle_cast({:ping, pid}, state) do
    GenServer.cast(pid, {:pong, "#{state["id"]} pong"})
    {:noreply, state}
  end

  def handle_cast({:pong, info}, state) do
    IO.inspect(info)
    {:noreply, state}
  end

  def ping({call_agent, agent_id}) do
    IO.inspect("#{call_agent} ping #{agent_id}")
    # GenServer.call(String.to_atom(agent_id), :ping)
    GenServer.cast(String.to_atom(agent_id), {:ping,String.to_atom(agent_id)})
  end

  def live_loop(state) do
    # 羊的逻辑：
    # 观测周边是不是安全的，如果是安全的，则采用一个随机的悠闲速度移动
    # 如果能够看到狼，则能跑就跑，跑不了小步慢走
    # 观测，获取周边的羊和狼的位置
    loc_x = state["location_x"]
    loc_y = state["location_y"]
    [agent_type, agent_id] = String.split(state["id"], "_")
    # obs_list = FoxSheep.Env.get_env_observation({agent_type, agent_id, loc_x, loc_y})
    # fox_list = Enum.filter(obs_list, fn [wait_agent_id, _, _] -> String.contains?(wait_agent_id, "fox") end)
    IO.inspect("我是一只羊 #{state["id"]}")
    if :random.uniform() > 0.5 do
        fox_number = ceil(:rand.uniform() * 4)
        __MODULE__.ping({state["id"], "fox_#{fox_number}"})
    end
    # # call policy, 给羊的移动方向，以及移动速度
    # {direction_x, direction_y} = generate_direction()
    # random_speed = case fox_list do
    #     nil ->
    #       generate_random_value(state["slow_speed_low"], state["slow_speed_high"])
    #     _ ->
    #       generate_random_value(state["fast_speed_low"], state["fast_speed_high"])
    #     end
    # action = {random_speed, direction_x, direction_y}
    # IO.inspect(action)
  end


  defp generate_random_value(min_value, max_value) do
    :rand.uniform() * (max_value - min_value) + min_value
  end

  defp generate_direction() do
    abs_angle = :rand.uniform() * :math.pi
    {:math.cos(abs_angle), :math.sin(abs_angle)}
  end

  def get_location(pid) do
    GenServer.call(pid, :get_location)
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


  def start_link([sheep_name]) do
    IO.puts("#{sheep_name} start!")
    GenServer.start_link(__MODULE__, sheep_name, name: String.to_atom(sheep_name))
  end

end
