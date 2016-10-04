defmodule ExParse.RegexParseTest do
  use ExUnit.Case, async: true
  doctest ExParse.RegexParse

  alias ExParse.RegexParse, as: RP

  @ippart_re "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
  @ipaddress_re Enum.join([@ippart_re, @ippart_re, @ippart_re, @ippart_re], "\\.")

  @ippart_ast {:group,
    {:union,
      {:union,
        [?2, ?5, {:set, '012345'}],
        [?2, {:set, '01234'}, {:set, '0123456789'}]
      },
      [zero_one: {:set, '01'}, set: '0123456789', zero_one: {:set, '0123456789'}]}}
  @ipaddress_ast [@ippart_ast, ?., @ippart_ast, ?., @ippart_ast, ?., @ippart_ast]

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
    "option" => [
      {"a?", {:ok, {:zero_one, ~c[a]}}},
      {"a?b", {:ok, [{:zero_one, ~c[a]}, ?b]}},
      {"a?bc", {:ok, [{:zero_one, ~c[a]}, ?b, ?c]}},
      {"ab?c", {:ok, [?a, {:zero_one, ~c[b]}, ?c]}},
      {"abc?", {:ok, [?a, ?b, {:zero_one, ~c[c]}]}},
    ],
    "groups" => [
      {"(a)", {:ok, {:group, ~c[a]}}},
      {"(ab)", {:ok, {:group, ~c[ab]}}},
      {"(a)b", {:ok, [{:group, ~c[a]}, ?b]}},
      {"a(b)", {:ok, [?a, {:group, ~c[b]}]}},
    ],
    "charsets" => [
      {"[a]", {:ok, {:set, ~c[a]}}},
      {"[ab]", {:ok, {:set, ~c[ab]}}},
      {"[a]b", {:ok, [{:set, ~c[a]}, ?b]}},
      {"a[b]", {:ok, [?a, {:set, ~c[b]}]}},
      {"[abc]", {:ok, {:set, ~c[abc]}}},
      {"[a-c]", {:ok, {:set, ~c[abc]}}},
    ],
    "negated charsets" => [
      {"[^a]", {:ok, {:neg_set, ~c[a]}}},
      {"[^ab]", {:ok, {:neg_set, ~c[ab]}}},
      {"[^a]b", {:ok, [{:neg_set, ~c[a]}, ?b]}},
      {"a[^b]", {:ok, [?a, {:neg_set, ~c[b]}]}},
      {"[^abc]", {:ok, {:neg_set, ~c[abc]}}},
      {"[^a-c]", {:ok, {:neg_set, ~c[abc]}}},
    ],
    "specials" => [
      {".",{:ok, :any}},
      {"a.", {:ok, [?a, :any]}},
      {".a", {:ok, [:any, ?a]}},
      {"^", {:ok, :bos}},
      {"$", {:ok, :eos}},
      {"\\d", {:ok, :digit}},
      {"\\D", {:ok, :no_digit}},
      {"\\s", {:ok, :whitespace}},
      {"\\S", {:ok, :no_whitespace}},
      {"\\w", {:ok, :word_character}},
      {"\\W", {:ok, :no_word_character}},
    ],
    "combinations" => [
      {"a?b*", {:ok, [{:zero_one, ~c[a]}, {:zero_more, ~c[b]}]}}
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
