defmodule ModelTest.Scenario.QuestionActor
    use GenServer

    def init(_) do
        # 定义智能体内部数据
        # {:ok, pid} = ModelTest.Core.AbstractActor.start_link()
    end


    def handle_cast({:question, question}, _from, state) do

        {:noreply, state}
    end

    def start_link(arg) do
        GenServer.start_link(__MODULE__, arg)
    end

    # ---------- api --------
    def input_question(pid, question) do
        # 通过键入一条问题


    end

end