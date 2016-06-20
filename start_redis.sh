#!/usr/bin/env bash


# Path to the redis binary
#
REDIS=/usr/local/bin/redis-server
DEFAULT_CONFIG=/etc/redis/redis.conf
SENTINEL_CONFIG=/etc/redis/sentinel.conf
REDIS_PORT=6379
SENTINEL_PORT=26379

: ${REDIS_RUN_USER:='redis'}
SU="su $REDIS_RUN_USER sh -c"

: ${EXTRA_OPTS:=''}
: ${ENABLE_REDIS:=true}
: ${ENABLE_SENTINEL:=false}
: ${SENTINEL_CLUSTER_NAME:='redis-cluster'}
: ${SENTINEL_CLUSTER_QUORUM:=2}
: ${SENTINEL_DOWN_AFTER_MILLISECONDS:=5000}
: ${SENTINEL_PARALLEL_SYNCS:=1}
: ${SENTINEL_FAILOVER_TIMEOUT:=10000}
: ${REDIS_MASTER_IP:=''}
: ${REDIS_PASSWORD:=''}
: ${IS_SLAVE:=false}

if [ -n "${RANCHER_SENTINEL_SERVICE}" -a $ENABLE_SENTINEL = true ]; then

  # Get my Rancher IP address
  MY_RANCHER_IP=$(curl http://rancher-metadata/2015-12-19/self/container/primary_ip)

  # If the ip is not found, it probably means we're using the host network stack
  # so use the host's ip instead
  if [[ $MY_RANCHER_IP = \Not* ]] ; then
    MY_RANCHER_IP=$(curl http://rancher-metadata/2015-12-19/self/host/agent_ip)
  fi
  echo "My IP is: $MY_RANCHER_IP"

  # Get the ips of any instances already in the given service
  service_ips=$(dig +short $RANCHER_SENTINEL_SERVICE | awk -v ORS=, '{print $1}' | sed 's/,$//')
  IFS=, read -ra ips <<<"$service_ips"

  # If we only one found IP, then we're the master
  if [ ${#ips[@]} -eq 1 ]; then
    REDIS_MASTER_IP=$MY_RANCHER_IP
  else
      # If there's more than one ip, connect to one of the other services and
      # get the master's ip address.
      for ip in ${ips[@]} ; do
        if [ $ip = $MY_RANCHER_IP ]; then
          continue
        fi

        REDIS_MASTER_IP=$(redis-cli -h $ip -p $SENTINEL_PORT sentinel get-master-addr-by-name redis-cluster | awk '{print $1; exit}')
        IS_SLAVE=true
        break
      done
  fi
fi

if [ $IS_SLAVE = true -a $ENABLE_REDIS = true ]; then
  sed -i "s/^# slaveof <masterip> <masterport>/slaveof $REDIS_MASTER_IP $REDIS_PORT/" $DEFAULT_CONFIG

  if [ -n $REDIS_PASSWORD ]; then
    sed -i "s/^# masterauth .*/masterauth $REDIS_PASSWORD/" $DEFAULT_CONFIG
  fi
elif [ $IS_SLAVE = false -a $ENABLE_REDIS = true ]; then
  if [ -n $REDIS_PASSWORD ]; then
    sed -i "s/^# requirepass .*/requirepass $REDIS_PASSWORD/" $DEFAULT_CONFIG
  fi
fi

if [ $ENABLE_SENTINEL =  true ]; then
  echo "The master's ip is: $REDIS_MASTER_IP"

  # Create the sentinel config file
  echo "bind 0.0.0.0" > $SENTINEL_CONFIG
  echo "port $SENTINEL_PORT" >> $SENTINEL_CONFIG
  echo "dir /tmp" >> $SENTINEL_CONFIG
  echo "sentinel monitor $SENTINEL_CLUSTER_NAME $REDIS_MASTER_IP $REDIS_PORT ${SENTINEL_CLUSTER_QUORUM}" >> $SENTINEL_CONFIG
  echo "sentinel down-after-milliseconds $SENTINEL_CLUSTER_NAME $SENTINEL_DOWN_AFTER_MILLISECONDS" >> $SENTINEL_CONFIG
  echo "sentinel parallel-syncs $SENTINEL_CLUSTER_NAME $SENTINEL_PARALLEL_SYNCS" >> $SENTINEL_CONFIG
  echo "sentinel failover-timeout $SENTINEL_CLUSTER_NAME $SENTINEL_FAILOVER_TIMEOUT" >> $SENTINEL_CONFIG

  if [ -n $REDIS_PASSWORD ]; then
    echo "sentinel auth-pass $SENTINEL_CLUSTER_NAME $REDIS_PASSWORD" >> $SENTINEL_CONFIG
  fi

  chown $REDIS_RUN_USER:$REDIS_RUN_USER $SENTINEL_CONFIG
fi

# Set backup schedule if we're given a cron time and redis is enabled
if [ -n "${CRON_TIME}" -a $ENABLE_REDIS = true ]; then
    exec /enable_backups.sh
fi

# Start redis if enabled
if [ $ENABLE_REDIS = true -a $ENABLE_SENTINEL = true ]; then
  $SU "$REDIS $DEFAULT_CONFIG $EXTRA_OPTS &"
  $SU "$REDIS $SENTINEL_CONFIG --sentinel"
elif [ $ENABLE_REDIS = false -a $ENABLE_SENTINEL = true ]; then
  $SU "$REDIS $SENTINEL_CONFIG --sentinel"
elif [ $ENABLE_REDIS = true -a $ENABLE_SENTINEL = false ]; then
  $SU "$REDIS $DEFAULT_CONFIG $EXTRA_OPTS"
fi
