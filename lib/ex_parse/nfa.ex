defmodule ExParse.Nfa do
  @moduledoc "A non-deterministic finite automaton."

  defstruct states: Map.new

  @all_chars 0..0xd7ff |> Enum.into(MapSet.new)

  def new(), do: %__MODULE__{states: %{
    0 => %{epsilon: [2]},
    2 => %{epsilon: [3]},
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
      x when x in [:epsilon, []] ->
        if to in nfa.states[from][:epsilon] do
          {next, nfa}
        else
          prev_goals = nfa.states[from][:epsilon] || []

          new_states = %{
            from => Map.merge(nfa.states[from], Enum.sort([to|prev_goals]))
          }
        end
      [c|cs]   ->
        new_states = %{
          from     => %{epsilon: [next]},
          next     => %{c     => [next + 1]},
          next + 1 => %{epsilon: [to]}
        }
        nfa = %{nfa | states: Map.merge(nfa.states, new_states)}
        from_regex(cs, nfa, next + 1, to, next + 2)
      {:union, left, right} ->
        {next, nfa} = from_regex(left, nfa, from, to, next)
        from_regex(right, nfa, from, to, next)
    end
  end

  defp connect(nfa, from, to, label)
  defp connect(%__MODULE__{} = nfa, from, to, label) do
    # TODO: implement
  end
end
