import ExBench.KV
import ExBench.Gen

seq_nums = numbers()
seq_hero = heroes()
shf_nums = Enum.shuffle(seq_nums)
shf_hero = Enum.shuffle(seq_hero)
ets_tables = create_ets_tables()
data_specs = [
  {"seq_nums", seq_nums, &identity/1},
  {"shf_nums", shf_nums, &identity/1},
  {"seq_hero", seq_hero, &get_id/1},
  {"shf_hero", shf_hero, &get_id/1},
]

File.mkdir_p! "bench/output"

maps =
for {name, data, key_fn} <- data_specs,
  into: %{},
  do: {name, fill_map(data, fn d -> {name, key_fn.(d)} end)}

for {ets_name, table} <- ets_tables,
    {data_name, data, key_fn} <- data_specs,
  do: fill_ets(table, data, fn d -> {ets_name, data_name, key_fn.(d)} end)

map_tests =
for {data_name, data, key_fn} <- data_specs do
  map = maps[data_name]
  key = "map_" <> data_name
  keys = Enum.map(data, fn d -> {data_name, key_fn.(d)} end)
  f = fn -> delete_all_map(map, keys) end
  {key, f}
end

pd_tests =
for {data_name, data, key_fn} <- data_specs do
  key = "pd_" <> data_name
  keys = Enum.map(data, fn d -> {data_name, key_fn.(d)} end)
  f = fn ->
    fill_pd(data, fn d -> {data_name, key_fn.(d)} end)
    delete_all_pd(keys)
  end
 {key, f}
end

ets_tests =
for {name, table} <- ets_tables,
    {data_name, data, key_fn} <- data_specs do
  keys = Enum.map(data, fn d -> {name, data_name, key_fn.(d)} end)
  key = "ets_" <> name <> "_" <> data_name
  f = fn ->
    delete_all_ets(table, keys)
  end
  {key, f}
end

(map_tests ++ pd_tests ++ ets_tests)
|> Map.new()
# |> IO.inspect()
|> Benchee.run([
  formatters: [
    Benchee.Formatters.HTML,
    Benchee.Formatters.JSON,
    Benchee.Formatters.Console,
  ],
  html: [file: "bench/output/kv_delete.html", auto_open: false],
  json: [file: "bench/output/kv_delete.json"],
])
