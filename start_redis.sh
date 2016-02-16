#!/usr/bin/env bash


# Path to the redis binary
#
REDIS=/usr/local/bin/redis-server
DEFAULT_CONFIG=/etc/redis/redis.conf
: ${REDIS_RUN_USER:='redis'}
SU="su $REDIS_RUN_USER sh -c"

: ${EXTRA_OPTS:=''}

# Set backup schedule
if [ -n "${CRON_TIME}" ]; then
    exec /enable_backups.sh
fi

# Run the command
#
$SU "$REDIS $DEFAULT_CONFIG $EXTRA_OPTS"
