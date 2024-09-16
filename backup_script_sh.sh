#!/bin/bash


ELASTICSEARCH_URL="https://192.168.51.192:9201"
SNAPSHOT_REPOSITORY="esrestore"  # Name of the snapshot repository
BACKUP_LOCATION="/home/me/project/poc/ccr/es-backup"  # Location to store snapshots

curl -XPUT -k -u elastic:liferay -H "Content-Type: application/json;charset=UTF-8" "${ELASTICSEARCH_URL}/_snapshot/${SNAPSHOT_REPOSITORY}" -d '{
  "type": "fs",
  "settings": {
    "location": "'${BACKUP_LOCATION}'",
	"compress": true
  }
}'

SNAPSHOT_NAME=es_snapshot$(date +"%Y-%m-%d-%H:%M:%S")

# This command will add the snapshot names in a text file
echo $SNAPSHOT_NAME >> /home/me/project/sebi/scripts/snapshot_name.txt

# Creating the snapshot
curl -XPUT -k -u elastic:liferay "${ELASTICSEARCH_URL}/_snapshot/${SNAPSHOT_REPOSITORY}/${SNAPSHOT_NAME}?wait_for_completion=true"

echo "Checking the STATUS"
while true; do
  STATUS=$(curl -s -XGET -k -u elastic:liferay "${ELASTICSEARCH_URL}/_snapshot/${SNAPSHOT_REPOSITORY}/${SNAPSHOT_NAME}/_status")
  if [[ $STATUS == *"SUCCESS"* ]]; then
    echo "Snapshot created successfully!"
    break
  fi
  echo ---------*********----------
  echo "Snapshot in progress..."
  echo ---------*********----------
  sleep 10
done
echo --------------*********---------------
echo Current Snapshot name is $SNAPSHOT_NAME
echo --------------*********---------------

echo "Details of all snapshot repository"
curl -XGET -k -u elastic:liferay "${ELASTICSEARCH_URL}/_cat/snapshots/esrestore?v=true&s=id&pretty"
