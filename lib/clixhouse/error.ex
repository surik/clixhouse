defmodule Clixhouse.Error do
  defexception [:message]

  def message(e) do
    e.message || ""
  end
end
