defmodule ExParse.Nfa do
  @moduledoc "A non-deterministic finite automaton."

  defstruct states: Map.new

  import EEx

  alias ExParse.Streamer

  @all_chars 0..0xd7ff |> Enum.into(MapSet.new)

  def new(), do: %__MODULE__{states: %{
    0 => %{epsilon: [2]},
    2 => %{},
    3 => %{epsilon: [1]},
    1 => %{},
  }}

  def from_regex(re) do
    id_stream = Streamer.new(4)
    case from_regex(re, new, 2, 3, id_stream) do
      {_, nfa} -> {:ok, nfa}
    end
  end

  def from_regex!(re) do
    {:ok, nfa} = from_regex(re)
    nfa
  end

  def to_graphviz(nfa, filename) do
    File.write(filename, nfa_dot(name: "foo", graph: nfa.states))
  end

  defp from_regex(re, nfa, from, to, next)
  defp from_regex(c, nfa, from, to, next) when is_integer(c), do: connect(nfa, from, to, <<c::utf8>>, next)
  defp from_regex(l, nfa, from, to, next) when is_list(l), do: do_seq(l, nfa, from, to, next)
  defp from_regex(:epsilon, nfa, from, to, next), do: connect(nfa, from, to, :epsilon, next)
  defp from_regex({:zero_more, re}, nfa, from, to, next) do
    {[a, b, c, d], next} = Streamer.take(next, 4)
    {next, nfa} = connect(nfa, a, b, :epsilon, next)
    {next, nfa} = from_regex(re, nfa, b, c, next)
    {next, nfa} = connect(nfa, c, d, :epsilon, next)
    {next, nfa} = connect(nfa, c, b, :epsilon, next)
    {next, nfa} = connect(nfa, from, a, :epsilon, next)
    connect(nfa, d, to, :epsilon, next)
  end
  defp from_regex({:union, l, r}, nfa, from, to, next) do
    {next, nfa} = from_regex(l, nfa, from, to, next)
    from_regex(r, nfa, from, to, next)
  end

  defp do_seq(seq, nfa, from, to, next)
  defp do_seq([], nfa, _from, _to, next), do: {next, nfa}
  defp do_seq([item], nfa, from, to, next), do: from_regex(item, nfa, from, to, next)
  defp do_seq([head|tail], nfa, from, to, next) do
    {[a], next} = Streamer.take(next, 1)
    {next, nfa} = from_regex(head, nfa, from, a, next)
    do_seq(tail, nfa, a, to, next)
  end

  defp connect(nfa, from, to, label, next)
  defp connect(%__MODULE__{} = nfa, from, to, label, next) do
    if to in (nfa.states[from][label] || []) do
      {next, nfa}
    else
      target_states = nfa.states[from][label] || []

      new_state_transitions = %{
        from => Map.merge(nfa.states[from] || %{}, %{label => Enum.sort([to|target_states])})
      }

      {next, %{nfa | states: Map.merge(nfa.states, new_state_transitions)}}
    end
  end

  function_from_file(:defp, :nfa_dot, "lib/nfa.dot.eex", [:assigns])
end
