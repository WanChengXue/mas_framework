defmodule ModelTest.Core.AbstractActor do
  use GenServer

  def init(_) do
    {:ok, %{"link_graph" => %{}}}
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def handle_call({:random_link, link_rule}, state) do
    # link_rule , 类似 %{type: int} 构成的map
    # link_graph, 类似 %{type: []} 构成的map
    # TODO hand-on
    # current_link_graph = state["link_graph"]
    # current_link_graph_length = Map.new(current_link_graph, fn {type, pid_list} -> {type, length(pid_list)} end)
    # need_add_graph_map = Map.new(link_rule, fn {type, link_number} -> {type, link_number - })
    # #  朝着abstract env询问当前环境中有多少个 actor
    # 把所有可连接的node都丢回去，全接连图
    ModelTest.Core.AbstractEnv.brief_actor()

    # # 挨个朝着这些actor发送请求，问一下是否当前有空，可否构建graph的连接
    # Enum.each(current_link_graph_length, fn{type, length} ->
    #   max_type
    # )
    # 如果说当前
  end

  # ------ abstract actor api, interface with abstract env and other abstract actor ---------

  def link_graph(link_rule) do
    # 传入 link规则，能够搜索出若干个abstract actor构成link map
  end
end
