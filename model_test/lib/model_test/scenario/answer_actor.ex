defmodule ModelTest.Scenario.AnswerActor do
  use GenServer

  def init(_) do
    # 此处是回答问题的actor的相关定义 
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end
end
