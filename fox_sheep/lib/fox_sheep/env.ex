defmodule FoxSheep.Env do
  use GenServer
  import YamlElixir
  require IEx

  def init([fox_number, sheep_number]) do
    game_config_path = Path.join(File.cwd!(), "lib/fox_sheep/game_config.yaml")
    {:ok, game_config} = YamlElixir.read_from_file(game_config_path)
    # 定义一些属性
    external_map = %{
      "fox_number" => fox_number,
      "sheep_number" => sheep_number
    }

    state = Map.merge(game_config, external_map)
    {:ok, state}
  end

  def handle_call(:get_location, _from, state) do
    # 返回一个map, %{{"fox_1", x, y}, {}} 形式
    fox_number = state["fox_number"]
    sheep_number = state["sheep_number"]

    fox_location_list =
      Enum.map(1..fox_number, fn i ->
        ["fox_#{i}"] ++ FoxSheep.Fox.get_location(String.to_atom("fox_#{i}"))
      end)

    sheep_location_list =
      Enum.map(1..sheep_number, fn i ->
        ["sheep_#{i}"] ++ FoxSheep.Sheep.get_location(String.to_atom("sheep_#{i}"))
      end)

    {:reply, fox_location_list ++ sheep_location_list, state}
  end

  def handle_call({:get_location, agent_id}, _from, state) do
    fox_number = state["fox_number"]
    sheep_number = state["sheep_number"]

    filter_fox = Enum.filter(1..fox_number, fn i -> "fox_#{i}" != agent_id end)
    filter_sheep = Enum.filter(1..sheep_number, fn i -> "sheep_#{i}" != agent_id end)
    fox_location_list =
      Enum.map(filter_fox, fn i -> 
            ["fox_#{i}"] ++ FoxSheep.Fox.get_location(String.to_atom("fox_#{i}"))
      end)

    sheep_location_list =
      Enum.map(filter_sheep, fn i ->
            ["sheep_#{i}"] ++ FoxSheep.Sheep.get_location(String.to_atom("sheep_#{i}"))
      end)

    {:reply, fox_location_list ++ sheep_location_list, state}
  end

  def handle_call(:get_common_info, _pid, state) do
    common_info = %{
      "world_length" => state["common"]["world_length"],
      "world_width" => state["common"]["world_width"],
      "sheep_length" => state["sheep"]["length"],
      "sheep_width" => state["sheep"]["width"],
      "fox_length" => state["fox"]["length"],
      "fox_width" => state["fox"]["width"]
    }

    {:reply, common_info, state}
  end

  def handle_call(:get_visual_radius, _pid, state) do
    radius_map = %{
        "fox" => state["fox"]["visual_radius"],
        "sheep" => state["sheep"]["visual_raius"]
    }
    {:reply, radius_map, state}
  end

  def handle_cast(:live_loop, state) do
    fox_number = state["fox_number"]
    sheep_number = state["sheep_number"]

    Enum.each(1..fox_number, fn i -> FoxSheep.Fox.start_loop(String.to_atom("fox_#{i}")) end)

    Enum.each(1..sheep_number, fn i -> FoxSheep.Sheep.start_loop(String.to_atom("sheep_#{i}")) end)

    IO.inspect("---- 所有agent都已经开始运行 ------")
    {:noreply, state}
  end

  def get_location() do
    GenServer.call(:fox_sheep_env, :get_location)
  end

  def get_location(agent_id) do
    GenServer.call(:fox_sheep_env, {:get_location, agent_id})
  end

  def get_visual_radius() do
    GenServer.call(:fox_sheep_env, :get_visual_radius)
  end


  def get_env_fox_sheep_common_info() do
    GenServer.call(:fox_sheep_env, :get_common_info)
  end

  def get_env_state() do
    fox_sheep_location_list = __MODULE__.get_location()
    common_info_map = __MODULE__.get_env_fox_sheep_common_info()
    Map.merge(common_info_map, %{"location" => fox_sheep_location_list})
  end

  def get_env_observation({agent_type, agent_index, loc_x, loc_y}) do
    location_list = __MODULE__.get_location("#{agent_type}_#{agent_index}")
    radius_map = __MODULE__.get_visual_radius()
    get_nearby_agent(location_list, loc_x, loc_y, radius_map[agent_type])
  end

  defp get_nearby_agent(location_list, x, y, visual_radius) do
    # 无论是fox还是sheep，返回视野范围内的所有agent位置
    Enum.filter(location_list, fn [_, loc_x, loc_y] -> :math.sqrt((loc_x - x) ** 2 + (loc_y - y)**2) < visual_radius end)
  end

  def live_loop() do
    GenServer.cast(:fox_sheep_env, :live_loop)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: :fox_sheep_env)
  end
end
