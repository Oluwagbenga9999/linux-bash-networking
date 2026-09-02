# Linux Bash Networking Assignment

This project contains a small set of bash utilities for checking local system health, disk usage, and network connectivity. The scripts are designed to collect runtime data from the current Linux environment and report useful status information.

## Project Scripts

- system-info.sh
  - Displays the hostname, current user, date/time, operating system, kernel version, uptime, CPU info, memory usage, and current working directory.

- disk-check.sh
  - Accepts a threshold value and optional path.
  - Prints the disk usage percentage.
  - Exits with code 0 when usage is below the threshold.
  - Exits with code 1 when usage reaches or exceeds the threshold.
  - Exits with code 2 for invalid input.

- network-check.sh
  - Validates the host or IP address argument.
  - Resolves the target and displays the resolved address.
  - Performs a basic connectivity check.
  - Lists network interface information.
  - Checks TCP connectivity for a supplied port if provided.
  - Validates port numbers between 1 and 65535.
  - Returns a non-zero exit code for invalid input without crashing.

- log.sh
  - Provides a reusable logger that writes timestamped entries to the logs directory.

## Usage

```bash
./system-info.sh
./disk-check.sh 80 /
./network-check.sh localhost 80
```

## Logging

All scripts append timestamped messages to:

```bash
logs/operations.log
```

Entries follow this format:

```text
YYYY-MM-DD HH:MM:SS - description
```

## Notes

- Default disk path is `/`.
- Valid threshold values are integers between 1 and 100.
- Valid ports are integers between 1 and 65535.
- Scripts are designed to fail gracefully and return non-zero exit codes for invalid input.
