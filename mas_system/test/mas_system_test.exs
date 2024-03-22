defmodule MasSystemTest do
  use ExUnit.Case
  doctest MasSystem

  test "greets the world" do
    assert MasSystem.hello() == :world
  end
end
