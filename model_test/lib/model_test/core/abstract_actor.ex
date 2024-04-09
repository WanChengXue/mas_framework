defmodule ModelTest.Core.AbstractActor do
  use GenServer

  def init(_) do
    {:ok, %{}}
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  # ------ abstract actor api, interface with abstract env and other abstract actor ---------
  

end
