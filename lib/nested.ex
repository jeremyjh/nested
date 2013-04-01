defmodule Nested do
  import Nested.Associate

  def assoc_in(structure, [], value) do
    value
  end

  # match a where clause
  defmacrop is_where?(head) do
    quote do
      is_list(unquote(head)) and 
      is_tuple(hd(unquote(head))) and 
      elem(hd(unquote(head)),0) == :where
    end
  end

  def assoc_in(structure, [head | tail], value) when is_where?(head) do
    index = Enum.find_index(structure, head[:where])
    replace_at(structure, index, 
      assoc_in(Enum.at!(structure, index), tail, value))
  end

  def assoc_in(structure, [head | tail], value) do
    assoc(structure, head, 
      assoc_in(get(structure,head), tail, value))
  end

  defp replace_at(list, index, value) do
    {first, second} = Enum.split(list, index)
    first ++ [value] ++ Enum.drop(second, 1)
  end
end
