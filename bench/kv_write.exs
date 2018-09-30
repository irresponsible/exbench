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

map_tests = 
for {data_name, data, key_fn} <- data_specs,
    key = "map_" <> data_name,
  do: {key, fn -> fill_map(data, key_fn) end}

pd_tests =
for {data_name, data, key_fn} <- data_specs,
    key = "pd_" <> data_name,
  do: {key, fn -> fill_pd(data, key_fn) end}

ets_tests =
for {name, table} <- ets_tables,
    {data_name, data, key_fn} <- data_specs,
  key = "ets_" <> name <> "_" <> data_name,
  do: {key, fn -> fill_ets(table, data, key_fn) end}  

(map_tests ++ pd_tests ++ ets_tests)
|> Map.new()
|> Benchee.run([
  formatters: [
    Benchee.Formatters.HTML,
    Benchee.Formatters.JSON,
    Benchee.Formatters.Console,
  ],
  html: [file: "bench/output/kv_write.html", auto_open: false],
  json: [file: "bench/output/kv_write.json"],
])
