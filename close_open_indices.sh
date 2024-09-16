#!/bin/bash

ES_HOST="192.168.51.192"
ES_PORT="9201"

# Get list of open indices
open_indices=$(curl -s -XGET -k -u elastic:liferay "https://${ES_HOST}:${ES_PORT}/_cat/indices?v&h=index,status" | grep open)

# Close each open index individually
for index in $open_indices; do
    index_name=$(echo $index | cut -f1)
    curl -s -XPOST -k -u elastic:liferay "https://${ES_HOST}:${ES_PORT}/${index_name}/_close?pretty"
    echo "--x--"
    echo "Closed index: ${index_name}"
    echo "--x--"
done

echo "===================================="
echo "Watch for the wildcard indices below if they are open close."
echo "===================================="
curl  -XGET -k -u elastic:liferay "https://${ES_HOST}:${ES_PORT}/_cat/indices/_all?expand_wildcards=all"


while true; do
  read -p "Do you want to close wildcard indices (yes/y/no/n) " answer
  case $answer in
    yes | y | Yes | YES )
      echo "Running the loop..."
      # Asking for the wildcard indices name
      read -p "Enter the wildcard indices name to close: " INDICES_NAME
      echo "Closing "
      curl -s -XPOST -k -u elastic:liferay "https://${ES_HOST}:${ES_PORT}/${INDICES_NAME}/_close?pretty"
      echo "--x--"
      ;;
    no | n | No | NO )
      echo "DETAILS OF ALL INDICES"
      curl  -XGET -k -u elastic:liferay "https://${ES_HOST}:${ES_PORT}/_cat/indices/_all?expand_wildcards=all"
      echo "Exiting..."
      exit
      ;;
    * )
      echo "Invalid answer. Please enter 'yes' or 'no'."
      ;;
  esac
done
