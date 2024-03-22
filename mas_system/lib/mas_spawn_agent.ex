defmodule MasSpawnAgent do
    use GenServer
    import Logger
    def init(_) do
        {:ok, %{:agent_name_list => []}}
    end


    def handle_call(message, _from, state) do
        {:reply, %{}, state}
    end


    def handle_cast({:spawn_new_agent, agent_name,  init_state, event_handler_map}, state) do
        {:noreply, state}
    end


    def handle_call({:unique_agent_name, agent_name}, _from, state) do

        {:reply, true, state}
    end


    def handle_call({:legal_event_map, event_handler_map}, _from, state) do

        {:reply, true, state}
    end

    def start_link(args) do 
        GenServer.start_link(__MODULE__, args, name: :mas_spawn_agent)
    end

    def spawn_new_agent({agent_name, init_state, event_handler_map}) do
        # 此处进行参数检测
        # agent name没有重名，init state是一个map, event_handler_map是合法的
        unique_name_flag = GenServer.call(:mas_spawn_agent, {:unique_agent_name, agent_name})
        init_state_legal_flag = GenServer.call(:mas_spawn_agent, {:legal_init_state, init_state})
        legal_event_handler_flag = GenServer.call(:mas_spawn_agent, {:legal_event_map, event_handler_map})
        # 只有上面三个flag都是true，才会进行编译操作
        GenServer.cast(:mas_spawn_agent, {:spawn_new_agent, agent_name, init_state, event_handler_map})
    end


    def user_call({message}) do

    end
end
