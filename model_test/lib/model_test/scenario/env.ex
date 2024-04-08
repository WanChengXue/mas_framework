defmodule ModelTest.Scenario.Env do
    #  --------- game controller --------
    use GenServer

    def start_link(arg) do
        GenServer.start_link(__MODULE__, arg)
    end

    # ----------- more, about game logic part --------
    def get_env_observation(pid) do
        GenServer.call(pid, :get_env_observation)
    end

    # ----------- genserver related -------
    def init(_) do
        # 给这个环境创建一个数据结构用来存放结构性数据
        env_state = ModelTest.Scenario.EnvState.new()
        # 需要启动抽象环境
        {:ok, abs_env_pid} = ModelTest.Core.AbstractEnv.start_link([])
        # 启动agent actor

        # 启动abstract_actor
        {:ok, env_state}
    end

    def handle_call(:get_env_observation, _from, state) do
        {:reply, state |> Map.drop([:__struct__]), state}
    end
end