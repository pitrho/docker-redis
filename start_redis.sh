#!/usr/bin/env bash


# Path to the redis binary
#
REDIS=/usr/local/bin/redis-server
DEFAULT_CONFIG=/etc/redis/redis.conf
USER=redis
SU="su $USER sh -c"

EXTRA_OPTS=${EXTRA_OPTS:=/etc/redis/redis.conf}

# Set backup schedule
if [ -n "${CRON_TIME}" ]; then
    exec /enable_backups.sh
fi

# Run the command
#
echo "Running $SU $REDIS $EXTRA_OPTS"
$SU "$REDIS $EXTRA_OPTS"
