defmodule ExParse.Nfa do
  @moduledoc "A non-deterministic finite automaton."

  defstruct states: Map.new

  @all_chars 0..0xd7ff |> Enum.into(MapSet.new)

  def new(), do: %__MODULE__{states: %{
    0 => %{epsilon: [2]},
    2 => %{},
    3 => %{epsilon: [1]},
    1 => %{},
  }}

  def from_regex(re) do
    case from_regex(re, new, 2, 3, 4) do
      {x, nfa} when is_integer(x) -> {:ok, nfa}
      res -> res
    end
  end

  defp from_regex(re, %__MODULE__{} = nfa, from, to, next) do
    case re do
      [] -> from_regex(:epsilon, nfa, from, to, next)
      :epsilon ->
        connect(nfa, from, to, :epsilon, next)
      char when is_integer(char) ->
        connect(nfa, from, to, <<char::utf8>>, next)
      seq when is_list(seq) ->
        from_regex(hd(seq), nfa, from, to, next)
#        new_states = %{
#          from     => %{c     => [to]},
#        }
#        nfa = %{nfa | states: Map.merge(nfa.states, new_states)}
#        from_regex(cs, nfa, next + 1, to, next + 2)
      {:union, left, right} ->
#        {next, nfa} = from_regex(left, nfa, from, to, next)
#        from_regex(right, nfa, from, to, next)
    end
  end

  defp connect(nfa, from, to, label, next)
  defp connect(%__MODULE__{} = nfa, from, to, label, next) do
    if to in (nfa.states[from][label] || []) do
      {next, nfa}
    else
      target_states = nfa.states[from][label] || []

      new_state_transitions = %{
        from => Map.merge(nfa.states[from], %{label => Enum.sort([to|target_states])})
      }

      {next, %{nfa | states: Map.merge(nfa.states, new_state_transitions)}}
    end
  end
end
