defmodule Nested do
  import Nested.Associate

  def assoc_in(structure, [], value) do
    value
  end

  def assoc_in(structure, [head | tail], value) do
    assoc(structure, head, 
      assoc_in(get(structure,head), tail, value))
  end
end
