#!/usr/bin/env bash
#
# Entrypoint to run stuff before the atmoz/sftp entrypoint.

set -Eeo pipefail

# Write the secrets to files.
./scripts/writesecrets.sh

# Build the users.conf file.
./scripts/buildusersconf.sh

# Finally, exec the original atmoz/sftp entrypoint.
exec /entrypoint
