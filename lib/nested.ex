defmodule Nested do
  alias Nested.Associate, as: NA

  def assoc_in(structure, [head | tail], value) do
    NA.assoc(
      structure, 
      head, 
      assoc_in(NA.get(structure,head), tail, value))
  end

  def assoc_in(structure, index, value) do
    value
  end
end
