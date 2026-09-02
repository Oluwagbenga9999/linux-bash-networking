# Assignment 3 — CI/CD with GitHub Actions

This project builds a local CI pipeline for a Bash-based diagnostics application. It validates shell scripts, runs tests, and builds/smoke-tests a Docker image without deploying to the cloud.

## Project Structure

- app/app.sh: Bash application entrypoint
- scripts/lint.sh: validates required files and shell syntax
- scripts/build.sh: builds the Docker image and runs smoke tests
- tests/test.sh: automated test suite
- .github/workflows/ci.yml: GitHub Actions workflow
- Dockerfile: builds the application container
- compose.yaml: runs the app locally with Docker Compose
- .dockerignore: excludes unnecessary files from the Docker build context
- grade.sh: local grading helper

## Application Commands

```bash
./app/app.sh help
./app/app.sh system-info
./app/app.sh check-host localhost
./app/app.sh check-port localhost 80
```

## Docker Usage

```bash
docker build -t devops-tool .
docker run --rm devops-tool help
docker run --rm devops-tool system-info
```

## Local Validation

```bash
chmod +x app/*.sh scripts/*.sh tests/*.sh grade.sh
./scripts/lint.sh
./tests/test.sh
./scripts/build.sh
./grade.sh
```

## GitHub Actions

The workflow is defined in .github/workflows/ci.yml and uses the dependency chain:

- validate
- test
- docker

The final workflow must pass after fixes are pushed.
