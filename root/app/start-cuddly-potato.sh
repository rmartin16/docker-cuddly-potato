#!/usr/bin/env sh
set -euf

# Perform mount check
/app/check-mount.sh

# setup cuddly potato
. /app/setup-feeder.sh

# Start cuddly potato
. /app/main.sh
