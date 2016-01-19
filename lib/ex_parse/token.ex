defmodule ExParse.Token do
  defstruct token: :none, newstate: :no_change, value: "", pos_info: {0, 0}
end
