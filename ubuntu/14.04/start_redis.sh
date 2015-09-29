#!/usr/bin/env bash


# Path to the redis binary
#
REDIS=/usr/local/bin/redis-server
DEFAULT_CONFIG=/etc/redis/redis.conf
USER=redis
SU="su $USER sh -c"


# See if this script was started without a config,
# file specified, in which case we'll start Redis
# with our default configuration file, which is
# bundled with the Docker image.
#
if [[ -z "$*" ]]; then
	ARGS=$DEFAULT_CONFIG
else
	if [[ "$*" =~ ^--[a-z] ]]; then
		ARGS="$DEFAULT_CONFIG $*"
	else
		ARGS="$*"
	fi
fi


# Run the command
#
echo "Running $SU \"$REDIS $ARGS\""
$SU "$REDIS $ARGS"
