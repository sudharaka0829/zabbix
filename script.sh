#!/bin/bash

# DB2 connection details
DB_USER="your_db_user"
DB_PASSWORD="your_db_password"
DB_DATABASE="your_db_name"
DB_HOST="your_db_host"
DB_PORT="your_db_port"

# Function to retrieve DB2 metrics
get_db2_metric() {
    metric_name=$1
    case $metric_name in
        "database_size")
            db2 "CONNECT TO $DB_DATABASE USER $DB_USER USING $DB_PASSWORD; SELECT DECIMAL(SUM(SIZE)/1024/1024, 10, 2) FROM SYSIBMADM.DB_HISTORY;" | grep -v "^$"
            ;;
        "tablespaces_usage")
            db2 "CONNECT TO $DB_DATABASE USER $DB_USER USING $DB_PASSWORD; SELECT TBSP_NAME, DECIMAL(USED_PAGES*PAGESIZE/1024/1024, 10, 2) FROM SYSIBMADM.TBSP_UTILIZATION;" | grep -v "^$"
            ;;
        "buffer_pool_hit_ratio")
            db2 "CONNECT TO $DB_DATABASE USER $DB_USER USING $DB_PASSWORD; SELECT DECIMAL(POOL_DATA_L_READS*100/(POOL_DATA_L_READS+POOL_INDEX_L_READS), 10, 2) FROM SYSIBMADM.MON_DB_SUMMARY;" | grep -v "^$"
            ;;
        "lock_waits")
            db2 "CONNECT TO $DB_DATABASE USER $DB_USER USING $DB_PASSWORD; SELECT COUNT(*) FROM SYSIBMADM.LOCKWAITS;" | grep -v "^$"
            ;;
        "active_connections")
            db2 "CONNECT TO $DB_DATABASE USER $DB_USER USING $DB_PASSWORD; SELECT COUNT(*) FROM SYSIBMADM.APPLICATIONS WHERE APPLICATION_STATUS='U';" | grep -v "^$"
            ;;
        "query_execution_time")
            db2 "CONNECT TO $DB_DATABASE USER $DB_USER USING $DB_PASSWORD; SELECT DECIMAL(AVG(TOTAL_EXECUTION_TIME)/1000, 10, 2) FROM SYSIBMADM.SNAPSQL;" | grep -v "^$"
            ;;
        "log_file_usage")
            db2 "CONNECT TO $DB_DATABASE USER $DB_USER USING $DB_PASSWORD; SELECT DECIMAL(TOTAL_LOG_USED/LOGFILS/1024/1024, 10, 2) FROM SYSIBMADM.SNAPDB;" | grep -v "^$"
            ;;
        "index_fragmentation")
            db2 "CONNECT TO $DB_DATABASE USER $DB_USER USING $DB_PASSWORD; SELECT DECIMAL(FLOAT(DENSITY), 10, 2) FROM SYSIBMADM.INDEXES;" | grep -v "^$"
            ;;
        "buffer_pool_usage")
            db2 "CONNECT TO $DB_DATABASE USER $DB_USER USING $DB_PASSWORD; SELECT POOL_NAME, DECIMAL(POOL_CUR_BUFFSZ/1024/1024, 10, 2) FROM SYSIBMADM.MON_BP_UTILIZATION;" | grep -v "^$"
            ;;
        *)
            echo "Unsupported metric"
            ;;
    esac
}

# Main script
metric=$1
case $metric in
    "database_size"|"tablespaces_usage"|"buffer_pool_hit_ratio"|"lock_waits"|"active_connections"|"query_execution_time"|"log_file_usage"|"index_fragmentation"|"buffer_pool_usage")
        get_db2_metric $metric
        ;;
    *)
        echo "Usage: $0 [databasen_size|tablespaces_usage|buffer_pool_hit_ratio|lock_waits|active_connections|query_execution_time|log_file_usage|index_fragmentation|buffer_pool_usage]"
        ;;
esac





#!/bin/bash

# DB2 connection details
DB_USER="your_db_username"
DB_PASS="your_db_password"
DB_NAME="your_db_name"

# Function to execute DB2 queries
execute_db2_query() {
    db2 connect to $DB_NAME user $DB_USER using $DB_PASS > /dev/null 2>&1
    db2 -x "$1"
}

# Function to get the database size
get_database_size() {
    execute_db2_query "SELECT DB_NAME, SUM(DATA_OBJECT_P_SIZE + INDEX_OBJECT_P_SIZE + LONG_OBJECT_P_SIZE) * PAGESIZE / 1024 / 1024 AS TOTAL_SIZE_MB FROM SYSIBMADM.ADMINTABINFO GROUP BY DB_NAME" | grep -v "DB_NAME" | awk '{print $1 ":" $2}'
}

# Function to get table usages
get_table_usages() {
    execute_db2_query "SELECT TABNAME, DATA_OBJECT_PAGES * PAGESIZE / 1024 / 1024 AS TABLE_SIZE_MB FROM SYSIBMADM.SNAPTABLES WHERE TABSCHEMA='your_schema_name'"
}

# Function to get buffer pool hit ratio
get_buffer_pool_hit_ratio() {
    execute_db2_query "SELECT BP_NAME, (100 - ((POOL_ASYNC_PAGES_READS + POOL_SYNC_PAGES_READS) * 100 / POOL_DATA_PAGES)) AS HIT_RATIO FROM SYSIBMADM.BP_HITRATIO"
}

# Function to get lock waits
get_lock_waits() {
    execute_db2_query "SELECT SUM(TOTAL_LOCK_WAITS) FROM SYSIBMADM.SNAPLOCK"
}

# Function to get active connections
get_active_connections() {
    execute_db2_query "SELECT COUNT(*) FROM SYSIBMADM.APPLICATIONS WHERE APPL_STATUS='UOW EXECUTING'"
}

# Function to get query execution times
get_query_execution_times() {
    execute_db2_query "SELECT AGENT_ID, EXECUTION_TIME FROM TABLE(MON_GET_AGENT('',-2)) AS AGENT"
}

# Function to get log file usage
get_log_file_usage() {
    execute_db2_query "SELECT TOTAL_LOG_AVAILABLE_PAGES * LOG_PAGE_SIZE / 1024 / 1024 AS LOG_FILE_USAGE_MB FROM SYSIBMADM.SNAPDB"
}

# Function to get index file usages
get_index_file_usages() {
    execute_db2_query "SELECT INDNAME, LEAF_BLOCKS * PAGESIZE / 1024 / 1024 AS INDEX_SIZE_MB FROM SYSIBMADM.SNAPINDEXES WHERE TABSCHEMA='your_schema_name'"
}

# Function to get index fragmentations
get_index_fragmentations() {
    execute_db2_query "SELECT INDNAME, (LEAF_NLEAF_DELLEAFS / LEAF_NLEAF_DELLEAFS_TOTAL_PAGES) * 100 AS FRAGMENTATION_PERCENTAGE FROM SYSIBMADM.SNAPINDEXES WHERE TABSCHEMA='your_schema_name'"
}

# Function to get buffer pool usages
get_buffer_pool_usages() {
    execute_db2_query "SELECT BP_NAME, POOL_USED_PAGES * PAGESIZE / 1024 / 1024 AS BUFFER_POOL_USAGE_MB FROM SYSIBMADM.SNAPBUFFERPOOL"
}

# Call functions to collect data
database_size=$(get_database_size)
table_usages=$(get_table_usages)
buffer_pool_hit_ratio=$(get_buffer_pool_hit_ratio)
lock_waits=$(get_lock_waits)
active_connections=$(get_active_connections)
query_execution_times=$(get_query_execution_times)
log_file_usage=$(get_log_file_usage)
index_file_usages=$(get_index_file_usages)
index_fragmentations=$(get_index_fragmentations)
buffer_pool_usages=$(get_buffer_pool_usages)

# Output data in a format readable by Zabbix
echo "DatabaseSize:$database_size"
echo "TableUsages:$table_usages"
echo "BufferPoolHitRatio:$buffer_pool_hit_ratio"
echo "LockWaits:$lock_waits"
echo "ActiveConnections:$active_connections"
echo "QueryExecutionTimes:$query_execution_times"
echo "LogFileUsage:$log_file_usage"
echo "IndexFileUsages:$index_file_usages"
echo "IndexFragmentations:$index_fragmentations"
echo "BufferPoolUsages:$buffer_pool_usages"

