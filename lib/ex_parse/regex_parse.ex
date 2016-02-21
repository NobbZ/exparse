defmodule ExParse.RegexParse do
  @moduledoc "Parser for regular expressions."
  
  @doc "Parses a given string or char list into its internal representation."
  def parse(string) when is_binary(string), do: string |> to_char_list |> parse
  def parse(string) when is_list(string), do: string |> :regex_parse.parse_string
end
