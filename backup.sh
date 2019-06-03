#!/bin/bash

if [ -z $PGHOST ] ; then
    echo "You must specify a PGHOST env var"
    exit 1
fi
if [ -z $PGPORT ] ; then
    echo "You must specify a PGPORT env var"
    exit 1
fi
if [ -z $PGPASSWORD ] ; then
    echo "You must specify a PGPASSWORD env var"
    exit 1
fi
if [ -z $PGUSER ] ; then
    echo "You must specify a PGUSER env var"
    exit 1
fi
if [ -z $PGDATABASE ] ; then
    echo "You must specify a PGDATABASE env var"
    exit 1
fi

if [ -z $GCS_BUCKET_POSTGRES ]; then
    echo "You must specify a google cloud storage GCS_BUCKET_POSTGRES address such as gs://my-backups/"
    exit 1
fi

if [ -z $BACKUP_NAME ]; then
    BACKUP_NAME=postgres_backup
fi

CURRENT_DATE=$(date -u +"%Y-%m-%dT%H%M%SZ")
BACKUP_SET="$BACKUP_NAME-$CURRENT_DATE.sql"

echo "Activating google credentials before beginning"
gcloud auth activate-service-account --key-file "$GOOGLE_APPLICATION_CREDENTIALS"

if [ $? -ne 0 ] ; then
    echo "Credentials failed; no way to copy to google."
    echo "Ensure GOOGLE_APPLICATION_CREDENTIALS is appropriately set."
fi

echo "=============== Postgres Backup ==============================="
echo "Beginning backup from $POSTGRES_HOST to /data/$BACKUP_SET"
echo "To google storage bucket $GCS_BUCKET_POSTGRES using credentials located at $GOOGLE_APPLICATION_CREDENTIALS"
echo "============================================================"

PGPASSWORD=${PGPASSWORD} pg_dump --no-owner --no-password -h ${PGHOST} -p ${PGPORT} -U ${PGUSER} ${PGDATABASE} > /data/$BACKUP_SET

echo "Backup size:"
du -hs "/data/$BACKUP_SET"

echo "Tarring -> /data/$BACKUP_SET.tar"
tar -cvf "/data/$BACKUP_SET.tar" "/data/$BACKUP_SET" --remove-files

echo "Zipping -> /data/$BACKUP_SET.tar.gz"
gzip -9 "/data/$BACKUP_SET.tar"

echo "Zipped backup size:"
du -hs "/data/$BACKUP_SET.tar.gz"

echo "Pushing /data/$BACKUP_SET.tar.gz -> $GCS_BUCKET_POSTGRES"
gsutil cp "/data/$BACKUP_SET.tar.gz" "$GCS_BUCKET_POSTGRES"

exit $?
