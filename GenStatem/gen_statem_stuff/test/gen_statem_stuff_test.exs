defmodule GenStatemStuffTest do
  use ExUnit.Case
  doctest GenStatemStuff

  test "greets the world" do
    assert GenStatemStuff.hello() == :world
  end
end
