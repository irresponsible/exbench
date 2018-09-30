defmodule StorageBench.MixProject do
  use Mix.Project

  def project do
    [
      app: :exbench,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :faker]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:faker, "~> 0.11"},
      {:benchee, "~> 0.13"},
      {:benchee_html, "~> 0.5"},
      {:benchee_json, "~> 0.5"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp aliases do
    [
      "bench.kv_read":   ["run bench/kv_read.exs"],
      "bench.kv_write":  ["run bench/kv_write.exs"],
      "bench.kv_delete": ["run bench/kv_delete.exs"],
      "bench.kv_rekey":  ["run bench/kv_rekey.exs"],
      "bench.kv": [
       "bench.kv_read",
       "bench.kv_write",
       "bench.kv_delete",
       "bench.kv_rekey",
      ],
      "bench.all": ["bench.kv"],
    ]
  end
 
end
