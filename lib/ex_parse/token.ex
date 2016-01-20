defmodule ExParse.Token do
  defstruct token: :none, newstate: :no_change, value: "", pos_info: ExParse.PosInfo.new("", 0, 0..0)
  @typedoc "Foo"
  @type t :: %__MODULE__{token: atom,
                         newstate: atom,
                         value: any,
                         pos_info: ExParse.PosInfo.t}
end
