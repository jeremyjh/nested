Code.require_file "../test_helper.exs", __FILE__

defmodule NestedTest do
  use ExUnit.Case
  import Nested

  defrecord Address, street: nil, city: nil, state: nil
  defrecord Person, first_name: nil, last_name: nil, address: nil

  setup do
    {:ok, 
     jeremy: Person.new(first_name: "Jeremy", last_name: "Huffman"), 
     home: Address.new(street: "101 First Street", city: "Anytown", state: "Denial"),
     tup:  {"first", "second"},
     words: [one: "one", two: "two"]}
  end

  test "assoc-in records", setup do
    jeremy = assoc_in(setup[:jeremy], [:address], setup[:home])
    assert jeremy.address.city == "Anytown"
  end

  test "assoc-in keywords", setup do
    more_words = [better: "best", worse: "worst"]
    words = assoc_in(setup[:words], [:inner], more_words)
    assert words[:inner][:better] == "best" 
  end

end
