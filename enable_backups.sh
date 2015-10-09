#!/bin/bash



BACKUP_LOG="/var/log/redis/backup.log"
touch $BACKUP_LOG

if [ -n "${CRON_TIME}" ]; then
    echo "=> Configuring cron schedule for database backups ..."

    [ -z "${S3_BUCKET}" ] && { echo "=> S3_BUCKET cannot be empty" && exit 1; }
    [ -z "${AWS_ACCESS_KEY_ID}" ] && { echo "=> AWS_ACCESS_KEY_ID cannot be empty" && exit 1; }
    [ -z "${AWS_SECRET_ACCESS_KEY}" ] && { echo "=> AWS_SECRET_ACCESS_KEY cannot be empty" && exit 1; }
    [ -z "${AWS_DEFAULT_REGION}" ] && { echo "=> AWS_DEFAULT_REGION cannot be empty" && exit 1; }

    # Set environment variables to run cron job
    echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >> /etc/cron.d/mysql_backup
    echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> /etc/cron.d/mysql_backup
    echo "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" >> /etc/cron.d/mysql_backup
    echo "S3_BUCKET=${S3_BUCKET}" >> /etc/cron.d/mysql_backup
    [ -n "${REDIS_DB}" ] && { echo "REDIS_DB=${REDIS_DB}" >> /etc/cron.d/mysql_backup; }
    [ -n "${MAX_BACKUPS}" ] && { echo "MAX_BACKUPS=${MAX_BACKUPS}" >> /etc/cron.d/mysql_backup; }
    [ -n "${EXTRA_OPTS}" ] && { echo "EXTRA_OPTS=${EXTRA_OPTS}" >> /etc/cron.d/mysql_backup; }
    echo "${CRON_TIME} /backup.sh >> ${BACKUP_LOG} 2>&1" >> /etc/cron.d/mysql_backup

    # start cron if it's not running
    if [ ! -f /var/run/crond.pid ]; then
        exec /usr/sbin/cron -f &
    fi

    tail -f /var/log/redis/backup.log
fi
