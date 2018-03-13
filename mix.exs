defmodule Clixhouse.Mixfile do
  use Mix.Project

  def project do
    [
      app: :clixhouse,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:db_connection, "~> 1.1"},
      {:hackney,       "~> 1.11.0"},
      {:poison,        "~> 3.1"}
    ]
  end
end
