defmodule ClixhouseTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  doctest Clixhouse

  alias Clixhouse.Result
  alias Clixhouse.Query

  test "connection with wrong URL fails" do
    assert capture_log(fn ->
      Clixhouse.start_link(url: "a://b")
      :timer.sleep(100)
    end) =~ "connection is invalid"

    assert capture_log(fn ->
      Clixhouse.start_link(url: :abc)
      :timer.sleep(100)
    end) =~ "connection is invalid"
  end

  test "connection when DB is not available" do
    assert capture_log(fn ->
      Clixhouse.start_link(url: "http://localhost:12345")
      :timer.sleep(500)
    end) =~ "connection is invalid"
  end

  test "query to string" do
    q = Query.new("SELECT 1")
    assert to_string q == "SELECT 1"
  end

  test "wrong query" do
    {:ok, pid} = Clixhouse.start_link([])
    {:error, error} = Clixhouse.query(pid, "SOME wrong QUERY")
    assert error.message =~ "DB::Exception: Syntax error"
  end

  test "keywords in query are case insensetive" do
    {:ok, pid} = Clixhouse.start_link([])
    result = %Result{columns: ["1"], num_rows: 1, rows: [{1}]}
    assert Clixhouse.query(pid, "SELECT 1") == {:ok, result}
    assert Clixhouse.query(pid, "select 1") == {:ok, result}
    assert Clixhouse.query(pid, "Select 1") == {:ok, result}
    assert Clixhouse.query!(pid, "SeLecT 1") == result
    assert Clixhouse.query(pid, "Drop table if Exists t") == {:ok, %Result{}}
  end

  test "simple query" do
    {:ok, pid} = Clixhouse.start_link([])
    assert Clixhouse.query(pid, "DROP TABLE IF EXISTS t") == {:ok, %Result{}}
    assert Clixhouse.query(pid, "CREATE TABLE t (a UInt8) ENGINE = Memory") == {:ok, %Result{}}
    assert Clixhouse.query(pid, "INSERT INTO t VALUES (1),(2),(3)") == {:ok, %Result{}}
    result = %Result{columns: ["a"], num_rows: 3, rows: [{1}, {2}, {3}]}
    assert Clixhouse.query(pid, "SELECT * FROM t") == {:ok, result}
  end

  test "simple query with DateTime" do
    {:ok, pid} = Clixhouse.start_link([])
    assert Clixhouse.query(pid, "DROP TABLE IF EXISTS t") == {:ok, %Result{}}
    assert Clixhouse.query(pid, "CREATE TABLE t (a UInt8, d DateTime) ENGINE = Memory") == {:ok, %Result{}}
    assert Clixhouse.query(pid, "INSERT INTO t VALUES (1, '2018-01-01 00:00:00')") == {:ok, %Result{}}
    result = %Result{columns: ["a", "d"], num_rows: 1, rows: [{1, "2018-01-01 00:00:00"}]}
    assert Clixhouse.query(pid, "SELECT * FROM t") == {:ok, result}
  end
end
