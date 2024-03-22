defmodule MAsInteractionAgent do
use GenServer

def init(_) do
    {:ok, %{}}
end


def handle_cast({:act, agent_action}, state) do
    # 上层策略传入一个动作进来，底层状态发生修改，无需回复操作
    {:noreply}
end

end