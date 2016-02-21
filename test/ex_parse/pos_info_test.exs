defmodule ExParse.PosInfoTest do
  use ExUnit.Case
  use ExCheck
  doctest ExParse.PosInfo

  alias ExParse.PosInfo, as: PI

  property :next_line do
    for_all {line, a, b} in {non_neg_integer, non_neg_integer, non_neg_integer} do
      [small, big] = Enum.sort [a, b]
      posinfo1 = %PI{line: line, char: small..big}
      posinfo2 = PI.next_line(posinfo1)
      posinfo2.line === line + 1 && posinfo2.char === 0..0
    end
  end
  
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
