Code.require_file "../test_helper.exs", __FILE__

defmodule AssociateTest do
  use ExUnit.Case
  alias Nested.Associate, as: NA

  defrecord Foo, bar: nil, baz: nil

  setup do
    {:ok, 
     foo: Foo.new(bar: "bar", baz: "baz"), 
     tup:  {"first", "second"},
     words: [one: "one", two: "two"]}
  end

  test "assoc record", setup do
    foo = NA.assoc(setup[:foo], :bar, "barzer")
    assert foo.bar == "barzer" 
  end

  test "get from record", setup do
    assert NA.get(setup[:foo], :bar) == "bar"
  end

  test "assoc tuple", setup do
    tup = NA.assoc(setup[:tup], 1, "seconder")
    assert elem(tup, 1) == "seconder"
  end

  test "get from tuple", setup do
    assert NA.get(setup[:tup], 1) == "second" 
  end

  test "assoc non-int tuple fails", setup do
    catch_error(NA.assoc(setup[:tup], :wat, "notme"))
  end

  test "assoc keywords list", setup do
    words = NA.assoc(setup[:words], :two, "twoer")
    assert words[:two] == "twoer"
  end

  test "get from keywords list", setup do
    assert NA.get(setup[:words], :one) == "one"
  end

end
