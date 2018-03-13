defmodule Clixhouse.Result do
  @moduledoc """
  Result struct returned from any successful query. These fields are:

    * `command` - An atom of the query command, for example: `:select` or
                  `:insert`;
    * `columns` - The column names;
    * `rows` - The result set. A list of tuples, each tuple corresponding to a
               row, each element in the tuple corresponds to a column;
    * `num_rows` - The number of fetched or affected rows;
  """

  @type t :: %__MODULE__{
    columns:  [String.t] | nil,
    rows:     [tuple] | nil,
    num_rows: integer | nil,
  }

  defstruct [:columns, :rows, :num_rows]
end
