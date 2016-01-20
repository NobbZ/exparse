defmodule ExParse.PosInfoTest do
  use ExUnit.Case
  doctest ExParse.PosInfo

  alias ExParse.PosInfo, as: PI

  test "creating a new one works with default values" do
    assert match?(%PI{}, PI.new())
  end

  test "creating only with filename does work" do
    assert match?(%PI{file: "foo"}, PI.new("foo"))
  end
end
