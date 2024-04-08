defmodule ModelTest.Scenario.EnvState do
    # 定义实际场景中，环境状态有什么
    # 暂时设计为轮询的方式查找后端数据，需要一个列表存放数据
    alias __MODULE__

    @enfoce_keys [
        :stream_list,
        :agent_map
    ]

    defstruct [:stream_list, :agent_map]


    def new() do
        %EnvState{stream_list: [], agent_map: %{}}
    end 
end
