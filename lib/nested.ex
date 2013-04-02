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
   
  List of fields - list of symbols / indices in update path
    * for Records, a symbol must indicate accessor e.g. :name for Person.name 
    * for dictionaries, whatever key value
    * for Tuples, a 0-based ordinal
    * for Lists: 
      * symbol (for Keyword list)
      * integer for ordinal position (position in list is preserved!)
      * [where: func] - pass a function to be used in Enum.find_index
      * [] - empty list (as last field) means prepend to list

  Update value can be a function - in that case a record update_ accessor or Dict.update will
  be called as appropriate.

  ## Examples 
  
  """
  alias Nested.Accessors, as: NA

  # passing a [where: func] in fields will find_index
  def update_in(structure, [field | rest], value) 
    when is_list(field) and is_tuple(hd(field)) and elem(hd(field),0) == :where do
    index = Enum.find_index(structure, field[:where])
    indices = [index] ++ rest
    update_in(structure, indices, value )
  end

  # passing [] as last field means prepend to list
  def update_in(list, [[]], value) when is_list(list), do: [value] ++ list

  # apply function value
  def update_in(structure, [field | []], func) when is_function(func) do
    NA.update(structure, field, func)
  end

  # typical entry point
  def update_in(structure, [field | rest], value) do
    NA.put(structure, field, 
      update_in(NA.get(structure,field), rest, value))
  end

  # all done
  def update_in(_, [], value), do: value
end
