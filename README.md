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

#Function to get the database size
get_database_size() {
    execute_db2_query "select sum(TBSP_USED_SIZE_KB) / 1024 / 1024 as DATABASE_SIZE from sysibmadm.TBSP_UTILIZATION" | grep -o '[0-9]*' | head -n1
}

# Function to get active connections
get_active_connections() {
    execute_db2_query "SELECT COUNT(*) FROM SYSIBMADM.APPLICATIONS WHERE APPL_STATUS='UOW EXECUTING'" |  tr -d [:space:]
}

# Function to get lock waits
get_lock_waits() {
    execute_db2_query "SELECT COUNT(*) FROM SYSIBMADM.LOCKWAITS;" |  tr -d [:space:]
}

# Function to get log file usage
get_log_file_usage() {
    execute_db2_query "select LOG_UTILIZATION_PERCENT from sysibmadm.MON_TRANSACTION_LOG_UTILIZATION" |  tr -d [:space:]
}

# Function to get table usages
get_table_usages() {
    execute_db2_query "SELECT TBSP_USED_PAGES * 100.0 / TBSP_TOTAL_PAGES AS USED_PERCENTAGE FROM SYSIBMADM.TBSP_UTILIZATION" | grep -v 'Division' |  tr -d [:space:]
}



#Call functions to collect data
db_status=$(get_db_status | sed 's/^[[:space:]]*//')
lock_waits=$(get_lock_waits | sed 's/^[[:space:]]*//')
database_size=$(get_database_size | sed 's/^[[:space:]]*//')
active_connections=$(get_active_connections | sed 's/^[[:space:]]*//')
log_file_usage=$(get_log_file_usage | sed 's/^[[:space:]]*//')
table_usages=$(get_table_usages | sed 's/^[[:space:]]*//')

#Output data in a format readable by Zabbix
echo "DatabaseStatus:$db_status"
echo "DBSize:$database_size"
echo "ActiveConnections:$active_connections"
echo "LockWaits:$lock_waits"
echo "LogFileUsage:$log_file_usage"
echo "TableUsages:$table_usages"

