defmodule ExParse.RegexParseTest do
  use ExUnit.Case, async: true
  # use ExCheck
  doctest ExParse.RegexParse

  alias ExParse.RegexParse, as: RP

  @example_table %{
    "concat" => [
      {"", {:ok, :epsilon}},
      {"a", {:ok, ~c[a]}},
      {"ab", {:ok, ~c[ab]}},
    ],
    "union" => [
      {"|a", {:ok, {:union, :epsilon, ~c[a]}}},
      {"a|", {:ok, {:union, ~c[a], :epsilon}}},
      {"a|b", {:ok, {:union, ~c[a],  ~c[b]}}},
      {"ab|c", {:ok, {:union, ~c[ab], ~c[c]}}},
      {"a|bc", {:ok, {:union, ~c[a], ~c[bc]}}},
    ],
    "repeat zero or more" => [
      {"a*", {:ok, {:zero_more, ~c[a]}}},
      {"a*b", {:ok, [{:zero_more, ~c[a]}, ?b]}},
      {"a*bc", {:ok, [{:zero_more, ~c[a]}, ?b, ?c]}},
      {"ab*c", {:ok, [?a, {:zero_more, ~c[b]}, ?c]}},
      {"abc*", {:ok, [?a, ?b, {:zero_more, ~c[c]}]}},
    ],
    "repeat one ore more" => [
      {"a+", {:ok, {:one_more, ~c[a]}}},
      {"a+b", {:ok, [{:one_more, ~c[a]}, ?b]}},
      {"a+bc", {:ok, [{:one_more, ~c[a]}, ?b, ?c]}},
      {"ab+c", {:ok, [?a, {:one_more, ~c[b]}, ?c]}},
      {"abc+", {:ok, [?a, ?b, {:one_more, ~c[c]}]}},
    ],
  }

  for {description, examples} <- @example_table do
    describe description do
      for {input, expect} <- examples do
        test "~r/#{input}/" do
          assert unquote(Macro.escape(expect)) = RP.parse(unquote(input))
        end
      end
    end
  end

  describe "option" do
    test "a?",   do: assert {:ok, {:zero_one, ~c[a]}}           = RP.parse("a?")
    test "a?b",  do: assert {:ok, [{:zero_one, ~c[a]}, ?b]}     = RP.parse("a?b")
    test "a?bc", do: assert {:ok, [{:zero_one, ~c[a]}, ?b, ?c]} = RP.parse("a?bc")
    test "ab?c", do: assert {:ok, [?a, {:zero_one, ~c[b]}, ?c]} = RP.parse("ab?c")
    test "abc?", do: assert {:ok, [?a, ?b, {:zero_one, ~c[c]}]} = RP.parse("abc?")
  end

  describe "groups" do
    test "(a)",  do: assert {:ok, {:group, ~c[a]}}       = RP.parse("(a)")
    test "(ab)", do: assert {:ok, {:group, ~c[ab]}}      = RP.parse("(ab)")
    test "(a)b", do: assert {:ok, [{:group, ~c[a]}, ?b]} = RP.parse("(a)b")
    test "a(b)", do: assert {:ok, [?a, {:group, ~c[b]}]} = RP.parse("a(b)")
  end

  describe "charsets" do
    test "[a]",   do: assert {:ok, {:set, ~c[a]}}       = RP.parse("[a]")
    test "[ab]",  do: assert {:ok, {:set, ~c[ab]}}      = RP.parse("[ab]")
    test "[a]b",  do: assert {:ok, [{:set, ~c[a]}, ?b]} = RP.parse("[a]b")
    test "a[b]",  do: assert {:ok, [?a, {:set, ~c[b]}]} = RP.parse("a[b]")
    test "[abc]", do: assert {:ok, {:set, ~c[abc]}}     = RP.parse("[abc]")
    test "[a-c]", do: assert {:ok, {:set, ~c[abc]}}     = RP.parse("[a-c]")
  end

  describe "negated charsets" do
    test "[^a]",  do: assert {:ok, {:neg_set, ~c[a]}}       = RP.parse("[^a]")
    test "[^ab]", do: assert {:ok, {:neg_set, ~c[ab]}}      = RP.parse("[^ab]")
    test "[^a]b", do: assert {:ok, [{:neg_set, ~c[a]}, ?b]} = RP.parse("[^a]b")
    test "a[^b]", do: assert {:ok, [?a, {:neg_set, ~c[b]}]} = RP.parse("a[^b]")
  end

  describe "specials" do
    test ".",  do: assert {:ok, :any}       = RP.parse(".")
    test "a.", do: assert {:ok, [?a, :any]} = RP.parse("a.")
    test ".a", do: assert {:ok, [:any, ?a]} = RP.parse(".a")

    test "^", do: assert {:ok, :bos} = RP.parse("^")
    test "$", do: assert {:ok, :eos} = RP.parse("$")

    test "\\d", do: assert {:ok, :digit}    = RP.parse("\\d")
    test "\\D", do: assert {:ok, :no_digit} = RP.parse("\\D")

    test "\\s", do: assert {:ok, :whitespace}    = RP.parse("\\s")
    test "\\S", do: assert {:ok, :no_whitespace} = RP.parse("\\S")

    test "\\w", do: assert {:ok, :word_character}    = RP.parse("\\w")
    test "\\W", do: assert {:ok, :no_word_character} = RP.parse("\\W")
  end

  describe "combinations" do
    test "a?b*", do: assert {:ok, [{:zero_one, ~c[a]}, {:zero_more, ~c[b]}]} = RP.parse("a?b*")
  end

  describe "simplify" do
    test "option" do
      {:ok, re_ast} = RP.parse "a?"
     assert {:union, :epsilon, ~c[a]} = RP.simplify(re_ast)
    end

    test "one or more" do
      {:ok, re_ast} = RP.parse "a+"
     assert [?a, {:zero_more, ~c[a]}] = RP.simplify(re_ast)
    end

    test "one or more of charset" do
      {:ok, re_ast} = RP.parse "[abc]+"
      assert [{:set, ~c[abc]}, {:zero_more, {:set, ~c[abc]}}] = RP.simplify(re_ast)
    end
  end

  test "complex case" do
    assert \
      {:ok, [{:group,
              {:union,
               {:union, [?2, ?5, {:set, '012345'}],
                [?2, {:set, '01234'}, {:set, '0123456789'}]},
               [zero_one: {:set, '01'}, set: '0123456789',
                zero_one: {:set, '0123456789'}]}}, :any,
             {:group,
              {:union,
               {:union, [?2, ?5, {:set, '012345'}],
                [?2, {:set, '01234'}, {:set, '0123456789'}]},
               [zero_one: {:set, '01'}, set: '0123456789',
                zero_one: {:set, '0123456789'}]}}, :any,
             {:group,
              {:union,
               {:union, [?2, ?5, {:set, '012345'}],
                [?2, {:set, '01234'}, {:set, '0123456789'}]},
               [zero_one: {:set, '01'}, set: '0123456789',
                zero_one: {:set, '0123456789'}]}}, :any,
             {:group,
              {:union,
               {:union, [?2, ?5, {:set, '012345'}],
                [?2, {:set, '01234'}, {:set, '0123456789'}]},
               [zero_one: {:set, '01'}, set: '0123456789',
                zero_one: {:set, '0123456789'}]}}]} \
      = RP.parse(
        "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\." <>
        "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\." <>
        "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\." <>
        "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
      )
  end
end
