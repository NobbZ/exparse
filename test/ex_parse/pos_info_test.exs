defmodule ExParse.PosInfoTest do
  use ExUnit.Case
  # use ExCheck
  doctest ExParse.PosInfo

  alias ExParse.PosInfo, as: PI

  test "creating a new one works with default values" do
    assert match?(%PI{}, PI.new())
  end

  test "creating only with filename does work" do
    assert match?(%PI{file: "foo"}, PI.new("foo"))
  end

  test "creating with filename and line does work" do
    assert match?(%PI{file: "foo", line: 10},
                  PI.new("foo", 10))
  end
end
