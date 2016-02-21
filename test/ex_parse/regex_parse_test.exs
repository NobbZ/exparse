defmodule ExParse.RegexParseTest do
  use ExUnit.Case, async: true
  use ExCheck
  doctest ExParse.RegexParse

  alias ExParse.RegexParse, as: RP

  @chars_to_escape '$|*+^-?()[]\\.'

  property :"single char string" do
    for_all c in char do
      {:ok, reTree} = RP.parse(<<c::utf8>>)
      [[c]] === reTree
    end
  end

  property :double_char_string do
    for_all {c1, c2} in {char, char} do
      {:ok, reTree} = RP.parse(<<c1::utf8, c2::utf8>>)
      [[c1, c2]] === reTree
    end
  end

  property :full_string do
    for_all s in unicode_string do
      implies s !== [] && not Enum.any?(@chars_to_escape, &Enum.member?(s, &1)) do
        {:ok, reTree} = RP.parse(s)
        [to_char_list(s)] === reTree
      end
    end
  end

  property :"single char unions" do
    for_all {c1, c2} in {char, char} do
      {:ok, reTree} = RP.parse(<<c1::utf8, ?|::utf8, c2::utf8>>)
      assert match?([{:union, [[^c1]], [[^c2]]}], reTree)
    end
  end

  property :"full string unions" do
    for_all {s1, s2} in {unicode_string, unicode_string} do
      implies s1 !== [] && s2 !== [] && not Enum.any?(@chars_to_escape, &Enum.member?(s1, &1)) && not Enum.any?(@chars_to_escape, &Enum.member?(s2, &1)) do
        {:ok, reTree} = RP.parse(s1 ++ '|' ++ s2)
        assert match?([{:union, [^s1], [^s2]}], reTree)
      end
    end
  end
      

  property :single_char_group do
    for_all c in char do
      {:ok, reTree} = RP.parse('(' ++ [c] ++ ')')
      [{:group, [[c]]}] === reTree
    end
  end

  property :long_group do
    for_all s in unicode_string do
      implies s !== [] && not Enum.any?(@chars_to_escape, &Enum.member?(s, &1)) do
        {:ok, reTree} = RP.parse('(' ++ s ++ ')')
        [group: [s]] === reTree
      end
    end
  end
end
