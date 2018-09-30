defmodule ExBench.Gen do

  def numbers(), do: Enum.to_list(1..10_000)
  def heroes(), do: Enum.map(1..10_000, &hero/1)

  def hero(id) do
    %{
      id: id,
      name: Faker.Name.name(),
      superhero_name: Faker.Superhero.name(),
      location: Faker.Pokemon.location(),
      planet: Faker.StarWars.planet(),
      preferred_bitterness: Faker.Beer.ibu(),
      version: Faker.App.semver(),
      color: Faker.Color.fancy_name(),
    }
  end

end
