#!/bin/bash

ROLE=$(redis-cli INFO | grep role | awk -F ":" '{print $2}')
if [ $ROLE != 'master']; then
  exit 0
fi

REDIS_DUMP_FILE=${REDIS_DB:=dump.rdb}
REDIS_DATA_DIR=${REDIS_DATA_DIR:=/var/lib/redis}

[ -z "${S3_BUCKET}" ] && { echo "=> S3_BUCKET cannot be empty" && exit 1; }
[ -z "${AWS_ACCESS_KEY_ID}" ] && { echo "=> AWS_ACCESS_KEY_ID cannot be empty" && exit 1; }
[ -z "${AWS_SECRET_ACCESS_KEY}" ] && { echo "=> AWS_SECRET_ACCESS_KEY cannot be empty" && exit 1; }
[ -z "${AWS_DEFAULT_REGION}" ] && { echo "=> AWS_DEFAULT_REGION cannot be empty" && exit 1; }

BACKUP_NAME="redis_`date +"%Y%m%d_%H%M%S"`.dump"

echo "=> Backup started ..."

# First, make sure the that the S3_BUCKET path exists
#
count=`/usr/bin/aws s3 ls s3://$S3_BUCKET | wc -l`

if [[ $count -eq 0 ]]; then
  echo "Path $S3_BUCKET not found."
  exit 1
fi


# Copy the backup to the S3 bucket
echo "Copying $BACKUP_NAME to S3 ..."
S3_FILE_PATH="s3://$S3_BUCKET/$BACKUP_NAME"
/usr/bin/aws s3 cp $REDIS_DATA_DIR/$REDIS_DUMP_FILE $S3_FILE_PATH


echo "=> Backup done"
