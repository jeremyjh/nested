Code.require_file "../test_helper.exs", __ENV__.file

defmodule AccessorTest do
  use ExUnit.Case
  alias Nested.Accessors, as: NA

  defrecord Foo, bar: nil, baz: nil

  setup do
    {:ok,
     foo: Foo.new(bar: "bar", baz: "baz"),
     tup:  {"first", "second"},
     words: [one: "one", two: "two"],
     map: %{:bar => "bar", :baz => "baz"},
     func: fn(v) -> String.slice(v,0,2)end}
  end

  test "put record", setup do
    foo = NA.put(setup[:foo], :bar, "barzer")
    assert foo.bar == "barzer"
  end

  test "get from record", setup do
    assert NA.get(setup[:foo], :bar) == "bar"
  end

  test "update record", setup do
    foo = NA.update(setup[:foo], :bar, setup[:func])
    assert foo.bar == "ba"
  end

  test "put tuple", setup do
    tup = NA.put(setup[:tup], 1, "seconder")
    assert elem(tup, 1) == "seconder"
  end

  test "get from tuple", setup do
    assert NA.get(setup[:tup], 1) == "second"
  end

  test "update tuple", setup do
    tup = NA.update(setup[:tup], 1, setup[:func])
    assert elem(tup, 1) == "se"
  end

  test "put non-int tuple fails", setup do
    catch_error(NA.put(setup[:tup], :wat, "notme"))
  end

  test "put keywords list", setup do
    words = NA.put(setup[:words], :two, "twoer")
    assert words[:two] == "twoer"
  end

  test "get from keywords list", setup do
    assert NA.get(setup[:words], :one) == "one"
  end

  test "put map", setup do
    map = NA.put(setup[:map], :bar, "barzer")
    assert map.bar == "barzer"
  end

  test "get from map", setup do
    assert NA.get(setup[:map], :bar) == "bar"
  end

  test "update map", setup do
    map = NA.update(setup[:map], :bar, setup[:func])
    assert map.bar == "ba"
  end
end
