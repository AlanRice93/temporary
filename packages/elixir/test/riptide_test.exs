defmodule RiptideTest do
  use ExUnit.Case
  doctest Riptide

  test "greets the world" do
    assert Riptide.hello() == :world
  end
end
