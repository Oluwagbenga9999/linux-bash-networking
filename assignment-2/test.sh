#!/usr/bin/env bash
set -u

bash -n app/diagnostic.sh
bash -n app/health-check.sh

chmod +x app/diagnostic.sh app/health-check.sh

echo "== help =="
./app/diagnostic.sh help >/tmp/diag_help.txt
cat /tmp/diag_help.txt

echo "== system =="
./app/diagnostic.sh system >/tmp/diag_system.txt
head -n 5 /tmp/diag_system.txt

echo "== disk =="
./app/diagnostic.sh disk >/tmp/diag_disk.txt
head -n 5 /tmp/diag_disk.txt

echo "== invalid =="
if ./app/diagnostic.sh invalid >/tmp/diag_invalid.txt 2>&1; then
    echo "invalid command unexpectedly succeeded" >&2
    exit 1
else
    echo "invalid command handled correctly"
    cat /tmp/diag_invalid.txt
fi

exit 0
