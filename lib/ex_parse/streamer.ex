defmodule ExParse.Streamer do

  @opaque t :: {__MODULE__, non_neg_integer}

  @spec new(non_neg_integer) :: t
  def new(n) do
    {__MODULE__, n}
  end

  @spec take(t, non_neg_integer) :: {list(non_neg_integer), t}
  def take(streamer, count), do: take(streamer, count, [])

  @spec take(t, non_neg_integer, list(non_neg_integer)) :: {list(non_neg_integer), t}
  defp take(streamer, 0, acc), do: {Enum.reverse(acc), streamer}
  defp take({__MODULE__, n}, count, acc), do: take({__MODULE__, n + 1}, count - 1, [n|acc])
end
