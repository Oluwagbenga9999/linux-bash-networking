# Assignment 2 — Dockerized Diagnostic CLI

This project builds a small Dockerized Bash CLI that can display Linux system information, check host reachability, and show disk usage. It is designed to run locally with Docker or Docker Compose.

## Project Structure

- app/diagnostic.sh: implements the CLI commands
- app/health-check.sh: validates the container is healthy
- Dockerfile: builds the lightweight Docker image
- compose.yaml: runs the application with Docker Compose
- .dockerignore: excludes unnecessary files from the build context
- test.sh: runs a basic validation suite
- grade.sh: local grading helper

## CLI Commands

```bash
./app/diagnostic.sh help
./app/diagnostic.sh system
./app/diagnostic.sh disk
./app/diagnostic.sh network localhost
```

## Docker Usage

```bash
docker build -t diagnostic-tool .
docker run --rm diagnostic-tool system
docker run --rm diagnostic-tool disk
docker run --rm diagnostic-tool help
```

## Docker Compose Usage

```bash
docker compose run --rm diagnostic system
```

## Exit Codes

- 0: success
- 1: runtime failure
- 2: invalid command or input

## Validation

```bash
chmod +x app/*.sh test.sh grade.sh
./test.sh
./grade.sh
```
