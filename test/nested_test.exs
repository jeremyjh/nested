Code.require_file "../test_helper.exs", __FILE__

defmodule NestedTest do
  use ExUnit.Case
  import Nested


  defrecord Address, street: nil, city: nil, state: nil
  defrecord Person, first_name: nil, last_name: nil, address: nil, phone_numbers: nil

  doctest Nested

  setup do
    {:ok, 
     jeremy: Person.new(first_name: "Jeremy", last_name: "Huffman"), 
     home: Address.new(street: "101 First Street", city: "Anytown", state: "Denial"),
     tup:  {"first", "second"},
     words: [one: "one", two: "two"]}
  end

  test "assoc-in records", setup do
    jeremy = put_in(setup[:jeremy], [:address], setup[:home])
    assert jeremy.address.city == "Anytown"
  end

  test "assoc-in keywords", setup do
    more_words = [better: "best", worse: "worst"]
    words = put_in(setup[:words], [:inner], more_words)
    assert words[:inner][:better] == "best" 
  end

  test "assoc-in records and keywords", setup do
    work = setup[:home].city "Barter Town"
    jeremy = put_in(setup[:jeremy], [:address], [home: setup[:home], work: work])
    jeremy = put_in(jeremy, [:address, :work, :state], "AU")
    jeremy = put_in(jeremy, [:address, :home], setup[:home].state "SC")
    assert jeremy.address[:work].state == "AU"
    assert jeremy.address[:work].city == "Barter Town"
    assert jeremy.address[:home].state == "SC"
  end

  test "assoc-in ordinal tuples, records and keywords", setup do
    work = setup[:home].city "Barter Town"
    jeremy = {put_in(setup[:jeremy], [:address], [home: setup[:home], work: work]),"frogs"}
    jeremy = put_in(jeremy, [0, :address, :work, :state], "AU")
    jeremy = put_in(jeremy, [0, :address, :home], setup[:home].state "SC")
    assert elem(jeremy,0).address[:work].state == "AU"
    assert elem(jeremy,0).address[:work].city == "Barter Town"
    assert elem(jeremy,0).address[:home].state == "SC"
  end

  test "assoc-in orddicts and records", setup do
    numbers = Dict.put(:orddict.new, :home, "867-5309")
    numbers = Dict.put(numbers, :work, "555-2121")
    jeremy = setup[:jeremy].phone_numbers(numbers)
    people = Dict.put(:orddict.new, :jeremy, jeremy)
    people = put_in(people, [:jeremy, :phone_numbers, :work], "555-9191")
    assert people[:jeremy].phone_numbers[:work] == "555-9191"
  end

  test "assoc-in HashDicts and records", setup do
    numbers = Dict.put(HashDict.new, :home, "867-5309")
    numbers = Dict.put(numbers, :work, "555-2121")
    jeremy = setup[:jeremy].phone_numbers(numbers)
    people = Dict.put(HashDict.new, :jeremy, jeremy)
    people = put_in(people, [:jeremy, :phone_numbers, :work], "555-9191")
    assert people[:jeremy].phone_numbers[:work] == "555-9191"
  end

  test "assoc-in :dict and records", setup do
    numbers = :dict.store(:home, "867-5309", :dict.new)
    numbers = :dict.store(:work, "555-2121", numbers)
    jeremy = setup[:jeremy].phone_numbers(numbers)
    people = :dict.store(:jeremy, jeremy, :dict.new)
    people = put_in(people, [:jeremy, :phone_numbers, :work], "555-9191")
    people = :dict.fetch(:jeremy, people)
    assert :dict.fetch(:work, people.phone_numbers) == "555-9191"
  end

  test "where clause find first", setup do
    addresses = [setup[:home].city("Sometown"), setup[:home] ]
    jeremy = setup[:jeremy].address addresses
    jeremy = put_in(jeremy, [:address, 
      [where: fn (v) -> v.city == "Sometown" end], 
      :street], "Another Street")
    assert  Enum.fetch!(jeremy.address,0).street == "Another Street"
  end
  test "where clause find last", setup do
    addresses = [setup[:home], setup[:home].city("Someother"), setup[:home].city "Sometown"]
    jeremy = setup[:jeremy].address addresses
    jeremy = put_in(jeremy, [:address, 
      [where: fn (v) -> v.city == "Sometown" end], 
      :street], "Another Street")
    assert  Enum.fetch!(jeremy.address,2).street == "Another Street"
  end

  test "where clause find middle", setup do
    addresses = [setup[:home], setup[:home].city("Sometown"), setup[:home].city("Someother")]
    jeremy = setup[:jeremy].address addresses
    jeremy = put_in(jeremy, [:address, 
      [where: fn (v) -> v.city == "Sometown" end], 
      :street], "Another Street")
    assert  Enum.fetch!(jeremy.address,1).street == "Another Street"
  end

  test "prepend to list", setup do
    jeremy = setup[:jeremy].phone_numbers ["555-9191", "555-1234"]
    jeremy = put_in(jeremy,[:phone_numbers, []], "867-5309")
    assert Enum.count(jeremy.phone_numbers) == 3
    assert jeremy.phone_numbers |> Enum.first == "867-5309"
  end

  test "update record with function", setup do
    work = setup[:home].city "Barter Town"
    jeremy = put_in(setup[:jeremy], [:address], [home: setup[:home], work: work])
    jeremy = update_in(jeremy, [:address, :work, :state], fn(v) -> String.slice(v,0,2) end)
    assert jeremy.address[:work].state == "De"
  end

  test "basic get_in", setup do
    work = setup[:home].city "Barter Town"
    jeremy = put_in(setup[:jeremy], [:address], [home: setup[:home], work: work])
    jeremy = update_in(jeremy, [:address, :work, :state], fn(v) -> String.slice(v,0,2) end)
    assert get_in(jeremy, [:address, :work, :state]) == "De"
  end
end
