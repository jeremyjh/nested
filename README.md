# Nested

  Updates a hierarchy of heterogeneous record/collection types, given a Structure,a list of Fields and a value (or update function).
  
  
  Structure can be any hierarchy/combination of:
  
    * Records    
    * Lists
    * Tuples
    * HashDict
    * Erlang's :dict and :orddict
   

  You can easily implement the Nested.Accessors protocol to support other structures. See the accessors.ex for examples.


  List of fields - list of symbols / indices in update path
  
    * for Records, an atom  must indicate accessor e.g. :name for Person.name 
    * for dictionaries, whatever key value
    * for Tuples, a 0-based ordinal
    * for Lists: 
      * atom (for Keyword list)
      * integer for ordinal position (position in list is preserved!)
      * [] - empty list (as last field) means prepend to list

  Update value can be a function - in that case a record update_ accessor or Dict.update will
  be called as appropriate.

  ## Examples 
```elixir

        import Nested

        defrecord Address, street: nil, city: nil, state: nil
        defrecord Person, first_name: nil, last_name: nil, address: nil, phone_numbers: nil

        home = Address.new(street: "101 First Street", city: "Anytown", state: "Denial")
        jeremy = Person.new(first_name: "Jeremy", last_name: "Huffman", address: home, phone_numbers: ["867-5309"])

        #simplest case - set a value in a nested record
        jeremy = put_in(jeremy, [:address, :state], "SC")
        
        IO.puts jeremy.address.state # "SC"

        #A hierarchy can be arbitrarily deep
        books = [first: [title: "A tale of two keywords", isbn: 12],second: [title: "For whom the code flows", isbn: 93]]
        library = [librarian: jeremy, books: books]

        #keyword lists (and dictionaries) are manipulated like records
        library = put_in(library, [:books, :first, :author], jeremy)

        IO.puts library[:books][:first][:author].first_name # "Jeremy"

        # With a plain list we can either replace an existing item by its ordinal index
        library = put_in(library, [:librarian, :phone_numbers, 0], "555-9191")

        # Or we can pre-pend items to it with an empty list []
        library = put_in(library, [:librarian, :phone_numbers, []], "867-5309")

        IO.inspect library[:librarian].phone_numbers # ["867-5309","555-9191"]

        #we can use update functions from records and dicts (and a fake one for lists)
        library = update_in(library, [:books, :first, :isbn], fn(v) -> v + 1 end)

        IO.puts library[:books][:first][:isbn] # 13

        #and yes, there is also a get_in ...

        IO.puts get_in library, [:books, :first, :author, :address, :street] # 101 First Street
```

For more examples take a look at nested_test.exs.
