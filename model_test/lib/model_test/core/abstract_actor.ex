defmodule ModelTest.Core.AbstractActor do
  use GenServer

  def init(_) do
    state = ModelTest.Core.ActorState.new()
    {:ok, state}
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def handle_call({:random_link, link_rule}, state) do
    ModelTest.Core.AbstractEnv.brief_actor()
  end

  def handle_cast({:set_actor_pid, actor_name, actor_pid, abs_actor_pid}, state) do
    new_state =
      state
      |> ModelTest.Core.ActorState.set_state("actor_name", actor_name)
      |> ModelTest.Core.ActorState.set_state("actor_pid", actor_pid)
      |> ModelTest.Core.ActorState.set_state("abs_actor_pid", abs_actor_pid)

    {:noreply, new_state}
  end

  def handle_call(:get_actor_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:broadcast, sender_pid, message}, state) do
    # TODO 本来是想将数据放在一个cache中，有一个函数一直运转，监控这个cache，当有数据就给实际agent推送
    {_, message_id, _} = message
    actor_pid = ModelTest.Core.ActorState.get_state(state, "actor_pid")
    GenServer.cast(actor_pid, {:broadcast, message})

    # 往cache中写一条record，当有结果处理返回回来之后，从cache中取出来数据返回回去
    new_state = ModelTest.Core.ActorState.add_message_receipt(state, message_id, sender_pid)
    {:noreply, new_state}
  end

  def handle_cast({:response, message_id, response_message}, state) do
    # 从state中取出收据
    receiver = ModelTest.Core.ActorState.get_message_receipt(state, message_id)
    GenServer.cast(receiver, {:reply, response_message})
    {:noreply, state}
  end

  def handle_cast({:reply, response_message}, state) do
    actor_pid = ModelTest.Core.ActorState.get_state(state, "actor_pid")
    GenServer.cast(actor_pid, response_message)
    {:noreply, state}
  end

  # ------ abstract actor api, interface with abstract env and other abstract actor ---------

  def set_actor_pid(actor_name, actor_pid, abs_actor_pid) do
    GenServer.cast(
      abs_actor_pid,
      {:set_actor_pid, actor_name, actor_pid, abs_actor_pid}
    )
  end

  def get_actor_state(abs_actor_pid) do
    GenServer.call(abs_actor_pid, :get_actor_state)
  end
end
