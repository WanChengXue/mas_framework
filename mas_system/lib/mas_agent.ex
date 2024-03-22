defmodule MasAgent do
    use GenServer
    def init(_) do
        {:ok, %{}}
    end


    def handle_call(message, _from, state) do
        {:reply, state, state}
    end

    def handle_cast(message, state) do
        {:noreply, state}
    end

    

    def live_loop() do
        # 这个智能体开始存活，决定自己当前步该做什么应该寻求策略的帮助
        # 策略可以是由用户固定后注入进来，也可以是通过grpc的方式请求得到
        
    end
end