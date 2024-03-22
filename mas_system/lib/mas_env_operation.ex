# 这个函数中是和环境进行交互的操作
defmodule MasEnvOperation do
    use GenServer
    def init(_) do
        {:ok, %{}}
    end


    def handle_call(:dispaly, _from, state) do
        # 此次操作将会和env_agent进行操作，返回一个数据map，具体格式由具体场景进行规定
    end


    def handle_cast() do

    end
end