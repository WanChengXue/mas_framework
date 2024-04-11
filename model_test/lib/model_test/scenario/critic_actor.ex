defmodule ModelTest.Scenario.CriticActor do
  use GenServer

  def init(_) do
    # 此处是回答问题的actor的相关定义 
    {:ok, pid} = ModelTest.Core.AbstractActor.start_link([])

    state =
      ModelTest.Scenario.CriticActorState.new()
      |> ModelTest.Scenario.CriticActorState.set_state("abs_actor_pid", pid)

    {:ok, state}
  end

  def handle_call(:get_actor_state, _from, state) do
    abs_actor_pid = ModelTest.Scenario.CriticActorState.get_state(state, "abs_actor_pid")
    abs_actor_state = ModelTest.Core.AbstractActor.get_actor_state(abs_actor_pid)
    {:reply, {state, abs_actor_state}, state}
  end

  def start_link(actor_name) do
    {:ok, pid} = GenServer.start_link(__MODULE__, actor_name)

    actor_name =
      case actor_name do
        "" -> Base.url_encode64(:crypto.strong_rand_bytes(16))
        _ -> actor_name
      end

    GenServer.cast(pid, {:set_actor_pid, actor_name, pid})
    {actor_name, pid}
  end

  def handle_cast({:set_actor_pid, actor_name, actor_pid}, state) do
    abstract_actor_pid = ModelTest.Scenario.CriticActorState.get_state(state, "abs_actor_pid")

    new_state =
      state
      |> ModelTest.Scenario.CriticActorState.set_state("actor_name", actor_name)
      |> ModelTest.Scenario.CriticActorState.set_state("actor_pid", actor_pid)

    ModelTest.Core.AbstractActor.set_actor_pid(actor_name, actor_pid, abstract_actor_pid)
    {:noreply, new_state}
  end

  def handle_cast({:set_attr, key, value}, state) do
    new_state = ModelTest.Scenario.CriticActorState.set_state(state, key, value)
    {:noreply, new_state}
  end

  def handle_call(:abs_actor_pid, _from, state) do
    abs_actor_pid = ModelTest.Scenario.CriticActorState.get_state(state, "abs_actor_pid")
    {:reply, abs_actor_pid, state}
  end

  # --------- 以上都是模板代码 ----------

  # 模板代码，对core的继承
  def handle_cast({:broadcast, message}, state) do
    try do
      GenServer.cast(self(), message)
      {:noreply, state}
    catch
      _error -> {:noreply, state}
    end
  end

  # ---------- api -----------
  def get_actor_state(actor_pid) do
    GenServer.call(actor_pid, :get_actor_state)
  end
end
