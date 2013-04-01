Code.require_file "../test_helper.exs", __FILE__

defmodule NestedTest do
  use ExUnit.Case
  import Nested

  defrecord Address, street: nil, city: nil, state: nil
  defrecord Person, first_name: nil, last_name: nil, address: nil, phone_numbers: nil

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

  test "assoc-in records and keywords", setup do
    work = setup[:home].city "Barter Town"
    jeremy = assoc_in(setup[:jeremy], [:address], [home: setup[:home], work: work])
    jeremy = assoc_in(jeremy, [:address, :work, :state], "AU")
    jeremy = assoc_in(jeremy, [:address, :home], setup[:home].state "SC")
    assert jeremy.address[:work].state == "AU"
    assert jeremy.address[:work].city == "Barter Town"
    assert jeremy.address[:home].state == "SC"
  end

  test "assoc-in ordinal tuples, records and keywords", setup do
    work = setup[:home].city "Barter Town"
    jeremy = {assoc_in(setup[:jeremy], [:address], [home: setup[:home], work: work]),"frogs"}
    jeremy = assoc_in(jeremy, [0, :address, :work, :state], "AU")
    jeremy = assoc_in(jeremy, [0, :address, :home], setup[:home].state "SC")
    assert elem(jeremy,0).address[:work].state == "AU"
    assert elem(jeremy,0).address[:work].city == "Barter Town"
    assert elem(jeremy,0).address[:home].state == "SC"
  end

  test "assoc-in orddicts and records", setup do
    numbers = Dict.put(:orddict.new, :home, "867-5309")
    numbers = Dict.put(numbers, :work, "555-2121")
    jeremy = setup[:jeremy].phone_numbers(numbers)
    people = Dict.put(:orddict.new, :jeremy, jeremy)
    people = assoc_in(people, [:jeremy, :phone_numbers, :work], "555-9191")
    assert people[:jeremy].phone_numbers[:work] == "555-9191"
  end

  test "assoc-in HashDicts and records", setup do
    numbers = Dict.put(HashDict.new, :home, "867-5309")
    numbers = Dict.put(numbers, :work, "555-2121")
    jeremy = setup[:jeremy].phone_numbers(numbers)
    people = Dict.put(HashDict.new, :jeremy, jeremy)
    people = assoc_in(people, [:jeremy, :phone_numbers, :work], "555-9191")
    assert people[:jeremy].phone_numbers[:work] == "555-9191"
  end

  test "assoc-in :dict and records", setup do
    numbers = :dict.store(:home, "867-5309", :dict.new)
    numbers = :dict.store(:work, "555-2121", numbers)
    jeremy = setup[:jeremy].phone_numbers(numbers)
    people = :dict.store(:jeremy, jeremy, :dict.new)
    people = assoc_in(people, [:jeremy, :phone_numbers, :work], "555-9191")
    people = :dict.fetch(:jeremy, people)
    assert :dict.fetch(:work, people.phone_numbers) == "555-9191"
  end

  test "where clause", setup do
    addresses = [setup[:home], setup[:home].city "Sometown"]
    jeremy = setup[:jeremy].address addresses
    jeremy = assoc_in(jeremy, [:address, 
      [where: fn (v) -> v.city == "Sometown" end], 
      :street], "Another Street")
    assert  Enum.at!(jeremy.address,1).street == "Another Street"
  end

end
