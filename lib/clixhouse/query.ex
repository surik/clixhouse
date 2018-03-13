defmodule Clixhouse.Query do
  @enforce_keys [:statement]
  defstruct statement: "",
            ref: nil

  alias __MODULE__

  def new(statement) do
    %Query{statement: statement,
           ref: make_ref()}
  end
end

defimpl DBConnection.Query, for: Clixhouse.Query do
  alias Clixhouse.Result

  def decode(_query, nil, _opts), do: %Result{}
  def decode(_query, "", _opts), do: %Result{}
  def decode(_query, result, _opts) do
    decoded = Poison.decode!(result)
    columns = for colum <- decoded["meta"], do: colum["name"]
    rows = for row <- decoded["data"], do: List.to_tuple(row)
    %Result{columns: columns, rows: rows, num_rows: decoded["statistics"]["rows_read"]}
  end

  def describe(query, _opts) do
    query
  end

  def encode(query, _params, _opts) do
    query.statement
    |> String.split(" ", parts: 2)
    |> upper_key()
    |> add_format()
  end

  def parse(query, _opts) do
    query
  end

  defp upper_key([key, other]), do: String.upcase(key) <> " " <> other

  defp add_format("SELECT" <> _ = statement), 
    do: statement <> " FORMAT JSONCompact"
  defp add_format("SHOW" <> _ = statement), 
    do: statement <> " FORMAT JSONCompact"
  defp add_format(statement), do: statement
end

defimpl String.Chars, for: Clixhouse.Query do
  alias Clixhouse.Query

  def to_string(%Query{statement: statement}) do
    IO.iodata_to_binary(statement)
  end
end
