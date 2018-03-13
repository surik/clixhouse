defmodule Clixhouse.Connection do
  @moduledoc false

  defstruct [url: "http://localhost:8123", client: nil]

  alias __MODULE__

  def new(),    do: connect(%Connection{})
  def new(nil), do: connect(%Connection{})
  def new(url), do: connect(%Connection{url: url})

  def connect(%Connection{url: url} = connection) when is_binary(url) do
    options = [pool: false, with_body: true]
    with %URI{scheme: scheme, host: host, port: port} <- URI.parse(connection.url),
         true <- ("http" == scheme and is_integer(port)), 
         {:ok, client} <- :hackney.connect(:hackney_tcp, host, port, options),
         client <- :hackney_manager.get_state(client),
         true <- alive?(client) 
    do
      %Connection{connection | client: client}
    else
      _ -> false
    end
  end
  def connect(_), do: false

  def alive?(%Connection{client: client}), do: alive?(client)
  def alive?(client) when is_tuple(client)  do
    request = {:get, "/", [], ""}
    case :hackney.send_request(client, request) do
      {:ok, 200, _, _body} -> 
        true
      _ -> 
        false
    end
  end
  def alive?(_), do: false
end
