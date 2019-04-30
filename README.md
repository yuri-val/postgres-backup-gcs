# postgres-backup

Create a backup of a specified postgres db to Google Cloud Storage

## Configuration

Set the following environment variables for the Docker container:


`PGHOST` Hostname of postgres db

`PGPORT` Port of postgres db

`PGUSER` Username of the postgres user

`PGDATABASE` Name of the database to be exported

`PGPASSWORD` Password of the postgres user

`GCS_BUCKET_POSTGRES` Google Cloud Storage bucket name

`BACKUP_NAME` Name of the backup file, will be appended by the current date

`GOOGLE_APPLICATION_CREDENTIALS` Path to mounted credentials file (google service account key json file)
