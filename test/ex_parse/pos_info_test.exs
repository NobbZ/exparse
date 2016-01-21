defmodule ExParse.PosInfoTest do
  use ExUnit.Case
  use ExCheck
  doctest ExParse.PosInfo

  alias ExParse.PosInfo, as: PI

  property :next_line do
    for_all line in non_neg_integer do
      posinfo1 = %PI{line: line}
      posinfo2 = PI.next_line(posinfo1)
      posinfo2.line === line + 1
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
