defmodule ModelTest.GameCacher do
    use GenServer

    def init(_) do
        {:ok, %{}}
    end


    def start_link(arg) do
        GenServer.start_link(__MODULE__, arg, name: :cacher)
    end

    def handle_cast({:add_new_game, game_id, pid}, state) do
        new_state = Map.put(state, game_id, pid)
        {:noreply, new_state}
    end


    def handle_call({:get_game_pid, game_id}, _from, state) do
        game_pid = Map.get(state, game_id)
        {:reply, game_pid, state}
    end

    # api
    def new_game() do
        # 定义这个传入的参数
        {:ok, pid} = ModelTest.Scenario.Env.start_link([])
        game_id = Base.url_encode64(:crypto.strong_rand_bytes(16))
        GenServer.cast(:cacher, {:add_new_game, game_id, pid})
        {game_id, pid}
    end


    def get_game_pid(game_id) do
        GenServer.call(:cacher, {:get_game_pid, game_id})
    end


    def stop_game() do

    end


    def load_game() do

    end


    def save_game() do

    end

end