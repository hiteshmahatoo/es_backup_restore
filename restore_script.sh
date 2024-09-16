#!/bin/bash

ELASTICSEARCH_URL="https://192.168.51.192:9201"
SNAPSHOT_REPOSITORY="esrestore"  # Name of the snapshot repository
BACKUP_LOCATION="/home/me/project/poc/ccr/es-backup"  # Location of snapshots

# Ask the user for the snapshot name
read -p "Enter the snapshot name to restore: " SNAPSHOT_NAME

# Notify elasticsearch to use specified snapshot repository as backup path
curl -XPUT -k -u elastic:liferay -H "Content-Type: application/json;charset=UTF-8" "${ELASTICSEARCH_URL}/_snapshot/${SNAPSHOT_REPOSITORY}" -d '{
  "type": "fs",
  "settings": {
    "location": "'${BACKUP_LOCATION}'",
    "compress": true
  }
}'

# Check if the snapshot exists
SNAPSHOT_EXISTS=$(curl -s -XGET -k -u elastic:liferay "${ELASTICSEARCH_URL}/_snapshot/${SNAPSHOT_REPOSITORY}/${SNAPSHOT_NAME}")

if [[ $SNAPSHOT_EXISTS == *"snapshot_missing_exception"* ]]; then
  echo "Error: Snapshot ${SNAPSHOT_NAME} does not exist."
  exit 1
fi

if [[ $SNAPSHOT_EXISTS == *"uuid"* ]]; then
  echo " "
  echo "Snapshot ${SNAPSHOT_NAME} exist."
fi

echo "RESTORING THE SNAPSHOT STARTED"

# Restore the snapshot
curl -XPOST -k -u elastic:liferay "${ELASTICSEARCH_URL}/_snapshot/${SNAPSHOT_REPOSITORY}/${SNAPSHOT_NAME}/_restore?wait_for_completion=true"

# Wait for the restore to complete
while true; do
  STATUS=$(curl -s -XGET -k -u elastic:liferay "${ELASTICSEARCH_URL}/_snapshot/${SNAPSHOT_REPOSITORY}/${SNAPSHOT_NAME}/_status")
  if [[ $STATUS == *"SUCCESS"* ]]; then
    echo "==============================="
    echo "RESTORE COMPLETED SUCCESSFULLY! SNAPSHOT NAME- ${SNAPSHOT_NAME}$"
    echo "==============================="
    break
  elif [[ $STATUS == *"snapshot_restore_exception"* ]]; then
    #statements
  fi
  echo "Restore in progress..."

  sleep 10
done
