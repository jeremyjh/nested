defmodule Nested do
  @moduledoc """
  Updates a hierarchy of heterogeneous record/collection types, given a Structure,
  a list of Fields and a value (or update function)

  Structure to modify can be any hierarchy/combination of:

    * Records
    * Lists
    * Tuples
    * HashDict
    * Erlang's :dict and :orddict
   
  List of fields - list of symbols / indices in update path:

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
        library = update_in(library, [:books, :first, :isbn], &1 + 1)

        IO.puts library[:books][:first][:isbn] # 13

        #and yes, there is also a get_in ...

        IO.puts get_in library, [:books, :first, :author, :address, :street] # 101 First Street

  For more examples take a look at nested_test.exs
  """
  alias Nested.Accessors, as: NA

  @doc """
  Put value into the designated path in the structure.
  fields is a list of atoms and/or indexes which provide the path and attribute to update.

  See moduledoc for list of structure types and more examples.
  
  ## Examples
      
      iex> put_in([parent: [child: [value: ""]]], [:parent, :child, :value], "something")
      [parent: [child: [value: "something"]]]           

      iex> defrecord Address, street: nil, city: nil, state: nil
      ...> defrecord Person, first_name: nil, last_name: nil, address: nil, phone_numbers: nil
      ...> home = Address.new(street: "101 First Street", city: "Anytown", state: "Denial")
      ...> jeremy = Person.new(first_name: "Jeremy", last_name: "Huffman", address: home, phone_numbers: ["867-5309"])
      ...> jeremy = put_in(jeremy, [:address, :state], "SC")
      ...> jeremy.address.state
      "SC"

  """
  def put_in(structure,fields,value) do
    do_update_in(structure,fields,value, false)
  end

  @doc """
  update value with provided functino in the designated path in the structure.
  fields is a list of atoms and/or indexes which provide the path and attribute to update.
  func is a function which will receive one parameter containing the value to be updated

  ## Examples
      
      iex> update_in([parent: HashDict.new([child: [age: 5]])], 
      ...>        [:parent, :child, :age], 
      ...>        &1 + 1)
      [parent: {HashDict,1,[child: [age: 6]]}]

  """
  def update_in(structure,fields,func) when is_function(func) do
    do_update_in(structure,fields,func, true)
  end

  @doc """
  Get the value from the path specified
  Use the same syntax as put/get to fetch values from arbitrary depth in
  a hierarchy of heterogenous structures.

  ## Examples
      
      iex> get_in([parent: [child: {"one", "two"}]], [:parent, :child, 1])
      "two"

  """
  def get_in(structure, [field | []]) do
    NA.get(structure,field)
  end
  def get_in(structure, [field | tail]) do
    get_in(NA.get(structure,field), tail)
  end

  # passing a [where: func] in fields will find_index
  defp do_update_in(structure, [field | rest], value, is_update) 
    when is_list(field) and is_tuple(hd(field)) and elem(hd(field),0) == :where do
    index = Enum.find_index(structure, field[:where])
    indices = [index] ++ rest
    do_update_in(structure, indices, value, is_update)
  end

  # passing [] as last field means prepend to list
  defp do_update_in(list, [[]], value, false) when is_list(list), do: [value] ++ list

  # apply function value
  defp do_update_in(structure, [field | []], func, true) do
    NA.update(structure, field, func)
  end

  # typical entry point
  defp do_update_in(structure, [field | rest], value, is_update)  do
    NA.put(structure, field, 
      do_update_in(NA.get(structure,field), rest, value, is_update))
  end

  # all done
  defp do_update_in(_, [], value, false), do: value
end
