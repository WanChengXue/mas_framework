defmodule ModelTest.Scenario.CriticActor do
  def init(arg) do
    # 此处是对其注意到的QA流程做出来的总结发言
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end
end
