defmodule ExParse.NfaTest do
  use ExUnit.Case, async: true
  # use ExCheck
  doctest ExParse.Nfa

  alias ExParse.Nfa
  alias ExParse.RegexParse, as: RP

  describe "concat" do
    test "" do
      assert {:ok, %Nfa{states: %{
        0 => %{:epsilon => [2]},
        2 => %{:epsilon => [3]},
        3 => %{:epsilon => [1]},
        1 => %{}
      }}} === "" |> RP.parse! |> Nfa.from_regex
    end

    test "a" do
      assert {:ok, %Nfa{states: %{
        0 => %{:epsilon => [2]},
        2 => %{"a"      => [3]},
        3 => %{:epsilon => [1]},
        1 => %{}
      }}} === "a"  |> RP.parse! |> Nfa.from_regex
    end

    test "ab" do
      assert {:ok, %Nfa{states: %{
        0 => %{:epsilon => [2]},
        2 => %{"a"      => [4]},
        4 => %{"b"      => [3]},
        3 => %{:epsilon => [1]},
        1 => %{}
      }}} === "ab" |> RP.parse! |> Nfa.from_regex
    end

    test "abc" do
      assert {:ok, %Nfa{states: %{
        0 => %{:epsilon => [2]},
        2 => %{"a"      => [4]},
        4 => %{"b"      => [5]},
        5 => %{"c"      => [3]},
        3 => %{:epsilon => [1]},
        1 => %{}
      }}} === "abc" |> RP.parse! |> Nfa.from_regex
    end
  end

  describe "union" do
    test "|a" do
      assert {:ok, %Nfa{states: %{
        0 => %{:epsilon => [2]},
        2 => %{:epsilon => [3],
               "a"      => [3]},
        3 => %{:epsilon => [1]},
        1 => %{}
      }}} === "|a" |> RP.parse! |> Nfa.from_regex
    end

    test "a|" do
      assert {:ok, %Nfa{states: %{
        0 => %{:epsilon => [2]},
        2 => %{:epsilon => [3],
               "a"      => [3]},
        3 => %{:epsilon => [1]},
        1 => %{}
      }}} === "a|" |> RP.parse! |> Nfa.from_regex
    end

    test "a|b" do
      assert {:ok, %Nfa{states: %{
        0 => %{:epsilon => [2]},
        2 => %{"a"      => [3],
               "b"      => [3]},
        3 => %{:epsilon => [1]},
        1 => %{}
      }}} === "a|b" |> RP.parse! |> Nfa.from_regex
    end

    test "ab|c" do
      assert {:ok, %Nfa{states: %{
        0 => %{:epsilon => [2]},
        2 => %{"a"      => [4],
               "c"      => [3]},
        4 => %{"b"      => [3]},
        3 => %{:epsilon => [1]},
        1 => %{}
      }}} = "ab|c" |> RP.parse! |> Nfa.from_regex
    end

    test "a|bc" do
      assert {:ok, %Nfa{states: %{
        0 => %{:epsilon => [2]},
        2 => %{"a"      => [3],
               "b"      => [4]},
        4 => %{"c"      => [3]},
        3 => %{:epsilon => [1]},
        1 => %{}
      }}} = "a|bc" |> RP.parse! |> Nfa.from_regex
    end
  end

  describe "repeat zero or more" do
    test "a*" do
      assert {:ok, %Nfa{states: %{
        0 => %{:epsilon => [2]},
        2 => %{:epsilon => [4]},
        4 => %{"a"      => [5],
               :epsilon => [3]},
        5 => %{:epsilon => [3,4]},
        3 => %{:epsilon => [1]},
        1 => %{},
      }}} === "a*" |> RP.parse! |> Nfa.from_regex
    end

    test "a*b" do
      assert {:ok, %Nfa{states: %{
        0 => %{:epsilon => [2]},
        2 => %{:epsilon => [5]},
        5 => %{"a"      => [6],
               :epsilon => [4]},
        6 => %{:epsilon => [4,5]},
        4 => %{"b"      => [3]},
        3 => %{:epsilon => [1]},
        1 => %{},
      }}} === "a*b" |> RP.parse! |> Nfa.from_regex
    end

#    test "a*bc", do: assert {:ok, [{:zero_more, ~c[a]}, ?b, ?c]} = RP.parse("a*bc")
#    test "ab*c", do: assert {:ok, [?a, {:zero_more, ~c[b]}, ?c]} = RP.parse("ab*c")
#    test "abc*", do: assert {:ok, [?a, ?b, {:zero_more, ~c[c]}]} = RP.parse("abc*")
  end

#  describe "repeat one ore more" do
#    test "a+",   do: assert {:ok,  {:one_more, ~c[a]}         } = RP.parse("a+")
#    test "a+b",  do: assert {:ok, [{:one_more, ~c[a]}, ?b]    } = RP.parse("a+b")
#    test "a+bc", do: assert {:ok, [{:one_more, ~c[a]}, ?b, ?c]} = RP.parse("a+bc")
#    test "ab+c", do: assert {:ok, [?a, {:one_more, ~c[b]}, ?c]} = RP.parse("ab+c")
#    test "abc+", do: assert {:ok, [?a, ?b, {:one_more, ~c[c]}]} = RP.parse("abc+")
#  end
#
#  describe "option" do
#    test "a?",   do: assert {:ok,  {:zero_one, ~c[a]}         } = RP.parse("a?")
#    test "a?b",  do: assert {:ok, [{:zero_one, ~c[a]}, ?b]    } = RP.parse("a?b")
#    test "a?bc", do: assert {:ok, [{:zero_one, ~c[a]}, ?b, ?c]} = RP.parse("a?bc")
#    test "ab?c", do: assert {:ok, [?a, {:zero_one, ~c[b]}, ?c]} = RP.parse("ab?c")
#    test "abc?", do: assert {:ok, [?a, ?b, {:zero_one, ~c[c]}]} = RP.parse("abc?")
#  end
#
#  describe "groups" do
#    test "(a)",  do: assert {:ok,  {:group, ~c[a]}     } = RP.parse("(a)")
#    test "(ab)", do: assert {:ok,  {:group, ~c[ab]}    } = RP.parse("(ab)")
#    test "(a)b", do: assert {:ok, [{:group, ~c[a]}, ?b]} = RP.parse("(a)b")
#    test "a(b)", do: assert {:ok, [?a, {:group, ~c[b]}]} = RP.parse("a(b)")
#  end
#
#  describe "charsets" do
#    test "[a]",   do: assert {:ok,  {:set, ~c[a]}     } = RP.parse("[a]")
#    test "[ab]",  do: assert {:ok,  {:set, ~c[ab]}    } = RP.parse("[ab]")
#    test "[a]b",  do: assert {:ok, [{:set, ~c[a]}, ?b]} = RP.parse("[a]b")
#    test "a[b]",  do: assert {:ok, [?a, {:set, ~c[b]}]} = RP.parse("a[b]")
#    test "[abc]", do: assert {:ok,  {:set, ~c[abc]}   } = RP.parse("[abc]")
#    test "[a-c]", do: assert {:ok,  {:set, ~c[abc]}   } = RP.parse("[a-c]")
#  end
#
#  describe "negated charsets" do
#    test "[^a]",  do: assert {:ok,  {:neg_set, ~c[a]}     } = RP.parse("[^a]")
#    test "[^ab]", do: assert {:ok,  {:neg_set, ~c[ab]}    } = RP.parse("[^ab]")
#    test "[^a]b", do: assert {:ok, [{:neg_set, ~c[a]}, ?b]} = RP.parse("[^a]b")
#    test "a[^b]", do: assert {:ok, [?a, {:neg_set, ~c[b]}]} = RP.parse("a[^b]")
#  end
#
#  describe "specials" do
#    test ".",  do: assert {:ok, :any}       = RP.parse(".")
#    test "a.", do: assert {:ok, [?a, :any]} = RP.parse("a.")
#    test ".a", do: assert {:ok, [:any, ?a]} = RP.parse(".a")
#
#    test "^", do: assert {:ok, :bos} = RP.parse("^")
#    test "$", do: assert {:ok, :eos} = RP.parse("$")
#
#    test "\\d", do: assert {:ok, :digit}    = RP.parse("\\d")
#    test "\\D", do: assert {:ok, :no_digit} = RP.parse("\\D")
#
#    test "\\s", do: assert {:ok, :whitespace}    = RP.parse("\\s")
#    test "\\S", do: assert {:ok, :no_whitespace} = RP.parse("\\S")
#
#    test "\\w", do: assert {:ok, :word_character}    = RP.parse("\\w")
#    test "\\W", do: assert {:ok, :no_word_character} = RP.parse("\\W")
#  end
#
#  describe "combinations" do
#    test "a?b*", do: assert {:ok, [{:zero_one, ~c[a]}, {:zero_more, ~c[b]}]} = RP.parse("a?b*")
#  end
#
#  describe "simplify" do
#    test "option" do
#      {:ok, re_ast} = RP.parse "a?"
#     assert {:union, :epsilon, ~c[a]} = RP.simplify(re_ast)
#    end
#
#    test "one or more" do
#      {:ok, re_ast} = RP.parse "a+"
#     assert [?a, {:zero_more, ~c[a]}] = RP.simplify(re_ast)
#    end
#
#    test "one or more of charset" do
#      {:ok, re_ast} = RP.parse "[abc]+"
#      assert [{:set, ~c[abc]}, {:zero_more, {:set, ~c[abc]}}] = RP.simplify(re_ast)
#    end
#  end
#
#  test "complex case" do
#    assert \
#      {:ok, [{:group,
#              {:union,
#               {:union, [?2, ?5, {:set, '012345'}],
#                [?2, {:set, '01234'}, {:set, '0123456789'}]},
#               [zero_one: {:set, '01'}, set: '0123456789',
#                zero_one: {:set, '0123456789'}]}}, :any,
#             {:group,
#              {:union,
#               {:union, [?2, ?5, {:set, '012345'}],
#                [?2, {:set, '01234'}, {:set, '0123456789'}]},
#               [zero_one: {:set, '01'}, set: '0123456789',
#                zero_one: {:set, '0123456789'}]}}, :any,
#             {:group,
#              {:union,
#               {:union, [?2, ?5, {:set, '012345'}],
#                [?2, {:set, '01234'}, {:set, '0123456789'}]},
#               [zero_one: {:set, '01'}, set: '0123456789',
#                zero_one: {:set, '0123456789'}]}}, :any,
#             {:group,
#              {:union,
#               {:union, [?2, ?5, {:set, '012345'}],
#                [?2, {:set, '01234'}, {:set, '0123456789'}]},
#               [zero_one: {:set, '01'}, set: '0123456789',
#                zero_one: {:set, '0123456789'}]}}]} \
#      = RP.parse(
#        "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\." <>
#        "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\." <>
#        "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\." <>
#        "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
#      )
#  end
end
