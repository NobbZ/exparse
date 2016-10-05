defmodule ExParse.RegexParse do
  @moduledoc "Parser for regular expressions."

  @type ast :: :foo

  @doc """
  Parses a given string or char list into its internal representation.

  Takes the `string` to parse and returns the internal representation.
  """
  @spec parse(String.t) :: {:ok, ast} | {:error, reason} when reason: any
  def parse(string) when is_binary(string), do: string |> to_char_list |> parse
  def parse(string) when is_list(string), do: string |> :regex_parse.parse_string

  @spec parse!(String.t) :: ast | no_return
  def parse!(string) do
    case parse(string) do
      {:ok, result} -> result
    end
  end

  def simplify(ast)
  def simplify(re) when is_integer(re), do: re
  def simplify({:set, chars}), do: {:set, chars}
  def simplify({:neg_set, chars}), do: {:neg_set, chars}
  def simplify({:zero_one, re}), do: {:union, :epsilon, simplify(re)}
  def simplify({:one_more, re}) do
    re = simplify(re)
    :regex_parse.flatten([re, {:zero_more, re}])
  end
  def simplify([h|t]), do: :regex_parse.flatten([simplify(h)|simplify(t)])
  def simplify([]), do: []
end
