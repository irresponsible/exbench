defmodule ExBench.KV do

  # Key functions

  def get_id(%{id: id}), do: id

  def identity(val), do: val

  # Functions for maps

  def fill_map(data, key_fn) do
    for d <- data,
      into: %{},
      do: {key_fn.(d), d}
  end

  def get_all_map(data, keys) do
    for k <- keys do
      _ = Map.get(data, k)
    end
    :ok
  end

  def change_key(n) when is_integer(n), do: n + 1000000
  def change_key(%{id: n}=i), do: %{ i | id: n + 1000000 }

  def delete_all_map(data, keys) do
    Enum.reduce(keys, data, &Map.delete(&2, &1))
    :ok
  end
  def change_key_map(key, acc, data) do
    old = Map.get(data, key)
    new = change_key(old)
    acc
    |> Map.delete(key)
    |> Map.put(key, new)
  end
  def change_keys_map(data, keys) do
    Enum.reduce(keys, data, &change_key_map(&1, &2, data))
    :ok
  end

  # Functions for process dictionaries

  def fill_pd(data, key_fn) do
    Enum.each(data, fn datum ->
    Process.put(key_fn.(datum), datum)
    end)
  end

  def get_all_pd(keys) do
    for k <- keys do
      _ = Process.get(k)
    end
    :ok
  end

  def delete_all_pd(keys) do
    for k <- keys do
      _ = Process.delete(k)
    end
  end

  def change_keys_pd(keys, key_fn) do
    for k <- keys do
      old = Process.delete(k)
      new = change_key(old)
      Process.put(key_fn.(new), new)
    end
  end
  # Functions for ets

  def ets_table(name, type), do: :ets.new(name, [:public, type])

  @ets_specs [
    {"set", :storage_bench_set, :set},
    {"ord", :storage_bench_ord, :ordered_set},
    {"bag", :storage_bench_bag, :bag},
    {"dup", :storage_bench_dup, :duplicate_bag},
  ]
  def create_ets_tables() do
    for {name, ets_name, type} <- @ets_specs,
      into: %{},
      do: {name, ets_table(ets_name, type)}
  end

  def fill_ets(table, data, key_fn) do
    for d <- data do
      true = :ets.insert(table, {key_fn.(d), d})
    end
  end

  def get_all_ets(table, keys) do
    for k <- keys do
      [_] = :ets.lookup(table, k)
    end
    :ok
  end

  def delete_all_ets(table, keys) do
    for k <- keys do
      true = :ets.delete(table, k)
    end
  end

  def change_keys_ets(table, keys, key_fn) do
    for k <- keys do
      [old] = :ets.lookup(table, k)
      true = :ets.delete(table, k)
      true = :ets.insert(table, {key_fn.(old), old})
    end
    :ok
  end

end

