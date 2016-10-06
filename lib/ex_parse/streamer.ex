defmodule ExParse.Streamer do
  def new(n) do
    {__MODULE__, n}
  end

  def take(streamer, count), do: take(streamer, count, [])

  defp take(streamer, 0, acc), do: {Enum.reverse(acc), streamer}
  defp take({__MODULE__, n}, count, acc), do: take({__MODULE__, n + 1}, count - 1, [n|acc])
end
