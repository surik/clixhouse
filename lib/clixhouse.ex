defmodule Clixhouse do
  @moduledoc """
  Pure Elixir driver for Yandex's [ClickHouse](https://clickhouse.yandex).
  It uses HTTP interface through DBConnection.
  """

  alias Clixhouse.Protocol
  alias Clixhouse.Query

  def start_link(opts) do
    DBConnection.start_link(Protocol, opts)
  end

  def query(conn, statement, _params \\ [], opts \\ []) do
    query = Query.new(statement)
    execute(conn, query, [], opts)
  end

  def query!(conn, statement, params \\ [], opts \\ []) do
    case query(conn, statement, params, opts) do
      {:ok, result} ->
        result
      {:error, err} ->
        raise err
    end
  end

  def execute(conn, query, params, opts \\ []) do
    case DBConnection.execute(conn, query, params, defaults(opts)) do
      {:error, %ArgumentError{} = err} ->
        raise err
      other ->
        other
    end
  end

  defp defaults(opts) do
    Keyword.put_new(opts, :timeout, 5000)
  end
end
