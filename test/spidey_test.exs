defmodule SpideyTest do
  use ExUnit.Case
  doctest Spidey

  test "greets the world" do
    assert Spidey.hello() == :world
  end
end
