

## This PoC was done by me to give a solution on elasticsearch backup and restore in a DC DR Environment of a Client.

**Requirement:** To take backup from DC and restore in DR also reverse this scenario with the updated data from DR to DC
**Environment Details:-**
DC - 3 Nodes Clustered ES
DR - 1 Node ES
**Scenario 1:** Took Backup in DC from Master Node url and Restored in DR which has one node and it was successfull.
**Scenario 2:** Took backup of DR after uploading more data in Doc & Library and then took Backup.
While restoring in DC I am getting an error `cannot restore index [liferay-20096-product-content-commerce-ml-recommendation] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"}],"type":"snapshot_restore_exception","reason":"[esrestore_trial1:elasticsearch_snapshot_trial1`

If you close all the indices try to restore it will throw error as system indices or wildcard indices starting with .(dot) etc. will not be closed in this case you need to find all the indices in the system i.e user defined + system by the command 

    curl  -XGET http://192.168.51.192:9201/_cat/indices/_all?expand_wildcards=all

After listing all the indices go to *elasticsearch.yml* in all nodes and add a property to allow wildcard deletion/closure of indices:

    action.destructive_requires_name: false 

and restart
after that close the the wildcard indices eg,

    curl -X POST "192.168.51.192:9201/.ds-ilm-history-5-2023.12.18-000001/_close?pretty"
    curl -X POST "192.168.51.192:9201/.ds-.logs-deprecation.elasticsearch-default-2023.12.18-000001/_close?pretty"

After closing all the indices the restore will be successfull.

Using the **backup_script.sh** script you can take backup in Elasticsearch by only changing the variable of URL, Repository, backup location. If ES in not http enabled then you can remove the -k -u username:password parameter. Make sure create the Backup Location folder before running this script.

**STEP 1:**
**Backup Script**: backup_script.sh This  script will also keep the Snapshot name in a text file which can be taken reference while restoring any particular snapshot with date and time

**STEP 2:**
**Close all open Indices:** close_open_indices.sh This script to be run before restoring. There is prompt in which user will asked if any wildcard indices need to be closed as all wildcard indices can't be closed in one go so the script will run in do while loop if user enters yes it will ask for wildcard indices name when we enter it will close.
Remember .security-7 will not get closed also it will not affect anything while restoring snapshots. so after all wildcard indices gets close type no or n in the prompt and the script will exit.

**STEP 3:
 Restore Indices:** restore_script.sh before running this script snapshot name should be ready from the snapshot_name.txt file and enter the snapshot name when prompt appears.

**STEP 4: (Optional) Open Indices:** open_indices.sh This is not required but still if there any need during any poc this script can be run to open indices in one go.
