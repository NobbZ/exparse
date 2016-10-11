defmodule ExParse.Dfa do
  @moduledoc "A non-deterministic finite automaton."

  defstruct states: Map.new

  alias ExParse.Streamer
  alias ExParse.Nfa

  def from_nfa(nfa = %Nfa{}) do
    nfa_table = Nfa.to_table(nfa)
  end
end
