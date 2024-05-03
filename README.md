#!/usr/bin/sh

# DB2 connection details
DB_USER="your_db_username"
DB_PASS="your_db_password"
DB_NAME="pegadb"

# Function to execute DB2 queries

. /home/db2inst1/sqllib/db2profile
execute_db2_query() {
    db2 connect to $DB_NAME > /dev/null 2>&1
    db2 -x "$1"
}

# Function to get db status
get_db_status() {
    execute_db2_query "SELECT DB_STATUS FROM TABLE(MON_GET_DATABASE(-2)) AS T"
}

#Call functions to collect data
db_status=$(get_db_status | sed 's/^[[:space:]]*//')

#Output data in a format readable by Zabbix
echo "DatabaseStatus:$db_status"
