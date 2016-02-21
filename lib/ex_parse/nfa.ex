defmodule ExParse.Nfa do
  @moduledoc "A non-deterministic finite automaton."
  
  defstruct states: Map.new, symbols: MapSet.new, delta: Map.new, start: nil, finals: MapSet.new
  @opaque t :: %__MODULE__{states:  Dict.t,
                           symbols: Set.t,
                           delta:   (state, symbol -> state),
                           start:   state | nil,
                           finals:  Set.t}

  @type symbol :: char
  @type state  :: integer

  @all_chars 0..0xd7ff |> Enum.into(MapSet.new)

  @doc """
  Creates a new non-deterministic finite automaton.

  `string` takes an elixir string or an charlist, while `tok_fun` is the
  function that shall be called on acceptance of the input.
  """
  def new(string, tok_fun) when is_binary(string), do: string |> to_char_list |> new(tok_fun)
  def new(string, tok_fun) when is_list(string) do
    nfa = %__MODULE__{}
    states = [{0, nil}, {1, tok_fun}] |> Enum.into(Map.new)
    start = 0
    finals = [1] |> Enum.into(MapSet.new)
    nfa = %{nfa | states: states, start: start, finals: finals}
  end
end
