defmodule ExParse.RegexParse do
  def parse(string) when is_binary(string), do: string |> to_char_list |> parse
  def parse(string) when is_list(string), do: string |> :regex_parse.parse_string
end
