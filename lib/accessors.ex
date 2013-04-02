defprotocol Nested.Accessors do
  @only [Record, Tuple, List]
  def put(structure, index, value)
  def get(structure, index)
  #def update(structure, index, value)
end

defimpl Nested.Accessors, for: HashDict do
  def put(dict, key, value) do
    Dict.put(dict, key, value)
  end

  def get(dict, key) do
    Dict.get(dict,key)
  end
end


defimpl Nested.Accessors, for: Tuple do
  
  #for :dicts
  def put(dict, key, value) 
    when is_record(dict) and elem(dict, 0) == :dict  do
    :dict.store(key, value, dict)
  end
  
  # for Records
  def put(record, attribute, value) when is_record(record) do
    module = elem(record,0)
    apply(module, attribute, [value, record])  
  end

  # for arbitrary tuples
  def put(tuple, index, value) when is_integer(index) do
    setelem(tuple, index, value)
  end

  # for :dicts 
  def get(dict, key)
    when is_record(dict) and elem(dict, 0) == :dict  do
    :dict.fetch(key, dict)
  end

  # for Records
  def get(record, attribute) when is_record(record) do
    module = elem(record,0)
    apply(module, attribute, [record])
  end

  # for arbitrary tuples
  def get(tuple, index) when is_integer(index) do
    elem(tuple,index)
  end

end

defimpl Nested.Accessors, for: List do
  # for Keywords or orddict
  def put(words, key, value) when is_atom(key) do
    Keyword.put(words, key, value)
  end

  #for index addressed lists - replace respecting position
  def put(list, index, value) when is_integer(index) do
    {first, second} = Enum.split(list, index)
    first ++ [value] ++ Enum.drop(second, 1)
  end

  # for Keywords or orddict
  def get(words, key) when is_atom(key) do
    Keyword.get(words,key)
  end

  #for index addressed lists
  def get(list, index) when is_integer(index) do
    Enum.at! list, index
  end
end
