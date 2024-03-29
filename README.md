# TimescaleDB metrics store for Membrane RTC Engine

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_rtc_engine_timescaledb.svg)](https://hex.pm/packages/membrane_rtc_engine_timescaledb)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/membrane_rtc_engine_timescaledb)
[![CircleCI](https://circleci.com/gh/jellyfish-dev/membrane_rtc_engine_timescaledb.svg?style=svg)](https://circleci.com/gh/jellyfish-dev/membrane_rtc_engine_timescaledb)

This repository allows storing metrics from `Membrane.RTC.Engine` reports in a TimescaleDB database.

It is part of [Membrane Multimedia Framework](https://membrane.stream).

## Installation

The package can be installed by adding `membrane_rtc_engine_timescaledb` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_rtc_engine_timescaledb, "~> 0.2.0"}
  ]
end
```

## Usage

To use `membrane_rtc_engine_timescaledb`, you have to have:

- running PostgreSQL database with Timescale extension
- config for `:membrane_rtc_engine_timescaledb`
- configured `Ecto` repo in your project
- `Ecto` migration calling `Membrane.RTC.Engine.TimescaleDB.Migrations.up/1`

To create such a migration, execute `$ mix ecto.gen.migration create_rtc_engine_timescaledb_tables`, what will create new migration module, and add there calls to `up/0` and `down/0` from `Membrane.RTC.Engine.TimescaleDB.Migrations`. Your new migration module should look like the example below

```elixir
defmodule MyApp.CreateRtcEngineTimescaledbTables do
  use Ecto.Migration

  alias Membrane.RTC.Engine.TimescaleDB.Migrations

  @spec up() :: :ok
  def up() do
    :ok = Migrations.up()
  end

  @spec down() :: :ok
  def down() do
    :ok = Migrations.down()
  end
end
```

Then, execute `$ mix ecto.migrate` to run the newly created migration.

To set up config for this library, put the following line in your config file:

```elixir
config :membrane_rtc_engine_timescaledb, repo: MyApp.Repo, cleanup_interval: 60 * 60, metrics_lifetime: 60 * 60 * 24
```

where

- `repo` (required) is a module in your project, that uses `Ecto.Repo`
- `cleanup_interval` (default: 1 hour) is the number of seconds between database cleanups
- `metrics_lifetime` (default: 24 hours) is the number of seconds that must pass from creation before each metric can be deleted during cleanup

## Metrics visualisation with Grafana

Metrics stored in the database using `membrane_rtc_engine_timescaledb` can be simply visualized using Grafana.
To start the dashboard with RTC Engine metrics, create a volume with Grafana configuration files taken from `priv/grafana/provisioning` and mount it in the Grafana container at the default location: `/etc/grafana/provisioning`.
When assembling an Elixir release with a dependency on `membrane_rtc_engine_timescaledb` the config files will be put in `lib/membrane_rtc_engine_timescaledb-0.1.0/priv/grafana/provisioning` directory inside the release.
If you want to put them in a different location (e.g. one that doesn't contain the library version, possibly changing over time), create an additional release step in `mix.exs` and use `Membrane.RTC.Engine.TimescaleDB.GrafanaHelper.cp_grafana_directory/1` inside, like in the example below:

```elixir
defmodule Example.MixProject do
  use Mix.Project

  def project do
    [
      project: :example_project,
      ...
      releases: [
        example_project: [
          steps: [:assemble, &cp_grafana_config/1]
        ]
      ]
    ]
  end

  defp cp_grafana_config(release) do
    Membrane.RTC.Engine.TimescaleDB.GrafanaHelper.cp_grafana_directory(release.path)
    release
  end
end
```

You can create a volume containing `priv/grafana/provisioning`, by declaring it in your `docker-compose.yml`

```yml
volumes:
  grafana-provisioning:
```

and adding it to the container with the Elixir project and to the Grafana container

```yml
services:
  ...
  elixir_project:
    ...
    volumes:
      - type: volume
        source: grafana-provisioning
        target: <path to grafana/provisioning in the related Docker image>
  grafana:
    ...
    depends_on:
      - elixir_project
    volumes:
      - type: volume
        source: grafana-provisioning
        target: /etc/grafana/provisioning
        read_only: true
        volume:
          nocopy: true
```

Beyond that, you have to set the following environment variables for your docker container

- `DB_NAME` - name of the database, that you store your metrics in
- `DB_USERNAME` - username used to log into the database
- `DB_PASSWORD` - password used to log into the database
- `DB_URL` - database URL in the form of `host:port`, eg. `localhost:5432`

To see an example, of how you can pass volumes and environment variables to the Docker containers, see `membrane_videoroom` [docker-compose.yml](https://github.com/membraneframework/membrane_videoroom/blob/metrics-visualisation/docker-compose.yml)

## Running tests

To start tests, you have to run `$ docker-compose up` command, to have a running database docker container. To set up the database before tests, run `$ MIX_ENV=test mix ecto.reset` in second terminal window. Tests can be run with `$ mix test --include long_running` command.

## Copyright and License

Copyright 2020, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_rtc_engine_timescaledb)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_template_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)
