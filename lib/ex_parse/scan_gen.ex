defmodule ExParse.ScanGen do
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

      def scan_string(input) do
        IO.puts "I do know about the following rules: #{inspect @rules}."
        IO.puts "But I can't do anything with the rules and the input (#{input}) given."
      end
    end
  end

  defmacro defrule(state \\ :global, regex, keywords)
  defmacro defrule(state, regex, do: block) do
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
  use ExParse.ScanGen

  defrule "foo", do: %{token | token: :foo}
end
