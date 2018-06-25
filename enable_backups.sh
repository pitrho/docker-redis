#!/bin/bash



BACKUP_LOG="/var/log/redis/backup.log"

if [ -n "${CRON_TIME}" ]; then
    echo "=> Configuring cron schedule for database backups ..."

    [ -z "${S3_BUCKET}" ] && { echo "=> S3_BUCKET cannot be empty" && exit 1; }
    [ -z "${AWS_ACCESS_KEY_ID}" ] && { echo "=> AWS_ACCESS_KEY_ID cannot be empty" && exit 1; }
    [ -z "${AWS_SECRET_ACCESS_KEY}" ] && { echo "=> AWS_SECRET_ACCESS_KEY cannot be empty" && exit 1; }
    [ -z "${AWS_DEFAULT_REGION}" ] && { echo "=> AWS_DEFAULT_REGION cannot be empty" && exit 1; }

    # Set environment variables to run cron job
    echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >> /etc/cron.d/redis_backup
    echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> /etc/cron.d/redis_backup
    echo "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" >> /etc/cron.d/redis_backup
    echo "S3_BUCKET=${S3_BUCKET}" >> /etc/cron.d/redis_backup
    [ -n "${REDIS_DB}" ] && { echo "REDIS_DB=${REDIS_DB}" >> /etc/cron.d/redis_backup; }
    echo "${CRON_TIME} root /backup.sh >> ${BACKUP_LOG} 2>&1" >> /etc/cron.d/redis_backup

    # Create the log output file (PIPE) if it does not exist
    if [ ! -a $BACKUP_LOG ]; then
        mkfifo $BACKUP_LOG
    fi

    # Clean up services we don't want to run
    rm -rf /etc/service/redis

    # run my_init
    /sbin/my_init &

    tail -f $BACKUP_LOG
else
    echo "=> Backups not scheduled. No CRON_TIME found."
fi
