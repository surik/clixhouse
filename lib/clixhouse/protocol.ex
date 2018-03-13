defmodule Clixhouse.Protocol do
  @moduledoc false

  use DBConnection

  alias Clixhouse.Error
  alias Clixhouse.Connection

  def connect(opts) do
    connection = Connection.new(opts[:url])
    if connection = Connection.connect(connection) do
      {:ok, connection}
    else
      {:error, %Error{message: "connection is invalid"}}
    end
  end
  
  def disconnect(_, connection) do
    :hackney.close(connection.client)
    :ok
  end

  def checkout(connection) do
    {:ok, connection}
  end

  def checkin(connection) do
    {:ok, connection}
  end
  
  def ping(connection) do
    if Clixhouse.Connection.alive?(connection),
      do: {:ok, connection},
      else: {:disconnect, %Error{message: "connection closed"}, connection}
  end

  def handle_prepare(query, _opts, connection) do
    {:ok, query, connection}
  end

  def handle_execute(_query, statement, _opts, connection) do
    request = {:post, "/", [], statement}
    case :hackney.send_request(connection.client, request) do
      {:ok, 200, _, body} -> 
        {:ok, body, connection}
      {:ok, _, _, error} -> 
        {:error, %Error{message: error}, connection}
      {:error, error} when is_atom(error)-> 
        {:disconnect, %Error{message: to_string(error)}, connection}
      error -> 
        {:disconnect, %Error{message: "#{inspect error}"}, connection}
    end
  end
end
