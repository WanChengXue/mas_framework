defmodule FoxSheep.Sheep do
  use GenServer
  import YamlElixir

  def init(sheep_name) do
    game_config = Path.join(File.cwd!(), "lib/fox_sheep/game_config.yaml")
    {:ok, game_params} = YamlElixir.read_from_file(game_config)
    # 随机初始化fox的位置
    world_length = game_params["common"]["world_length"]
    world_width = game_params["common"]["world_width"]
    sheep_length = game_params["sheep"]["length"]
    sheep_width = game_params["sheep"]["width"]
    location_x = generate_location(sheep_length, world_length - sheep_length)
    location_y = generate_location(sheep_width, world_width - sheep_width)

    external_map = %{
      "location_x" => location_x,
      "location_y" => location_y,
      "id" => sheep_name,
      "stop_flag" => false
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

  def live_loop(state) do
    IO.inspect("我是一只羊 #{state["id"]}")
  end

  defp generate_location(min_value, max_value) do
    :rand.uniform() * (max_value - min_value) + min_value
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
