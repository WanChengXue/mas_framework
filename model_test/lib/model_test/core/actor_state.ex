defmodule ModelTest.Core.ActorState do
  alias __MODULE__

  @enfoce_keys [
    :mail_box
  ]

  defstruct [:mail_box]

  def new() do
    %ActorState{mail_box: MapSet.new()}
  end
end
