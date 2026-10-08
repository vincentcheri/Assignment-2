# Diagnostic Tool

A small Bash-based Linux diagnostic CLI packaged as a Docker image.

## Build

From the repository root:

```sh
docker build -t diagnostic-tool .
```

## Run

```sh
docker run --rm diagnostic-tool system
docker run --rm diagnostic-tool network example.com
docker run --rm diagnostic-tool disk
docker run --rm diagnostic-tool help
```

The CLI commands are:

- `system` — show Linux distribution, kernel, architecture, uptime, and memory.
- `network <host>` — send one ping to a hostname or IP address.
- `disk` — show filesystem usage.
- `help` — show command usage.

Invalid commands or input exit with status `2`. Operational failures (for example,
a host that cannot be reached) exit with status `1`; successful commands exit with
status `0`.

## Docker Compose

Run a command through Compose:

```sh
docker compose run --rm diagnostic system
docker compose run --rm diagnostic network example.com
docker compose run --rm diagnostic disk
```

## Tests

`test.sh` builds the Docker image and checks help, system, disk, invalid commands,
and missing arguments. Run it with:

```sh
./test.sh
```

`grade.sh` runs those image tests and validates the Compose configuration:

```sh
./grade.sh
```
