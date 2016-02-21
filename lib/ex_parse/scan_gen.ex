defmodule ExParse.ScanGen do
  @moduledoc """
  This module provides some macros which helps you to build you a scanner.

  To use it simply `use ExParse.ScanGen` in your module:

  ```
  defmodule Example do
    use ExParse.ScanGen
  end
  ```

  You will then have acces to the macros of this module, also some functions
  will be generated for you. Also it will alias the Module `ExParse.Token` as
  `Token`.

  The following functions will be injected into your module:

  * `scan_string/1` which tokenizes a string (or a charlist)
  * `scan_file/1` which does load a given file and tokenizes it
  """
  defmacro __using__(_) do
    quote do
      import ExParse.ScanGen

      alias ExParse.Token, as: Token

      @rules %{}
      @rule_count 0

      @before_compile ExParse.ScanGen
    end
  end

  defmacro __before_compile__(env) do
    quote do
      IO.puts "There were #{@rule_count} rules defined in #{__MODULE__}"
      @rules (@rules |> Enum.map(fn({key, list}) -> {key, Enum.reverse(list)} end) |> Enum.into(%{}))
      
      @doc """
      Scans a given string and returns a `List` of `ExParse.Token`s.
      """
      @spec scan_string(input :: String.t | list) :: [ExParse.Token.t]
      def scan_string(input) when is_list(input), do: input |> to_string |> scan_string
      def scan_string(input) when is_binary(input) do
        IO.puts "I do know about the following rules: #{inspect @rules}."
        IO.puts "But I can't do anything with the rules and the input (#{input}) given."
      end

      @doc """
      Opens a given file and scans it, returning a `List` of `ExParse.Token`s.
      """
      @spec scan_file(file :: String.t | list) :: :ok #[ExParse.Token.t]
      def scan_file(file) when is_list(file), do: file |> to_string |> scan_file
      def scan_file(file) when is_binary(file) do
        IO.puts "I do know about the following rules: #{inspect @rules}."
        IO.puts "But I can't do anything with the rules and the file {#{file}) right now."
      end
    end
  end

  @doc """
  Defines a tokenisation rule.

  ## Parameters

  ### `state`

  Describes the state in which we need to be that this rule is allowed to fire.
  It's default value is `:start`.

  Every rule is only checked when we are in its defined state.

  There are some special states available:

  * `:start`: This is the starting state of the tokenizer.
  * `:global`: Rules that are in this state will be appended into to every other
    state. First the special rules for a given state will be checked in order,
    before we try the `:global` ones. You are not allowed to make a rule
    explicitely change into this state.
  * `:no_change`: Trying to change into this state means, to stay were we are.
    Any rule which shall only fire in this state will never fire.

  ### `regex`

  The regular expression that is used for this rule.

  You have to write them as raw strings using doublequoted syntax. 

  ### `do_block`

  Whatever you have in your `do_block` will be injected into a funtion.

  This block has the following variables availabe:

  * `token`: It is an `ExParse.Token`, you may modify it to your needs or even
    discard it.
  * `old_state`: This is the state the tokenizer is in when it started the
    current scan. This can either be used to do different things in `:global`
    rules or to make sure we stay in the same state as we were before.

  ## Returnvalues

  There are multiple types of return types possible:

  * We get an `ExParse.Token`-struct, which means that we have succesfully
    extracted a token from the input string.
  * The atom `:skip`, which means that we have successfully extracted a token,
    but we don't need it. Something similar is done for example when scanning
    a comment in many languages.
  * The tuple `{:skip, new_state}`. This is actually the same as above but does
    also change the current state of the scanner.
  * The atom `:no_match`, which actually means, “yes, I have extracted something,
    but I don't consider it usefull, please try the remaining scanners.”
  """
  defmacro defrule(state \\ :start, regex, do_block)
  defmacro defrule(state, regex, do: block) do
    binary_regex = "^#{Macro.unescape_string(regex, &Regex.unescape_map/1)}"
    IO.inspect Regex.compile(binary_regex)
    IO.inspect regex
    rule_name = String.to_atom("rule_#{state}_#{regex}")
    IO.puts "Found #{rule_name}"
    quote do
      @rules Map.put(@rules, unquote(state), [{unquote(rule_name), unquote(regex)}|Map.get(@rules, unquote(state), [])])
      @rule_count @rule_count + 1
      defp unquote(rule_name)(var!(token), var!(old_state)) do
        _ = var!(old_state)
        
        unquote(block)
      end
    end
  end
end

defmodule FooBar do
  @moduledoc """
  This is an undocumented dummy and will be removed in the future.
  """

  use ExParse.ScanGen

  defrule "fo\no", do: %{token | token: :foo}
end
