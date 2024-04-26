[db2inst1@ASOMUWFDB401 db2]$ db2 connect to pegadb
 
   Database Connection Information
 
Database server        = DB2/LINUXX8664 11.5.8.0
SQL authorization ID   = DB2INST1
Local database alias   = PEGADB
 
[db2inst1@ASOMUWFDB401 db2]$ db2 "SELECT DECIMAL(SUM(SIZE)/1024/1024, 10, 2) FROM SYSIBMADM.DB_HISTORY"
SQL0206N  "SIZE" is not valid in the context where it is used.  SQLSTATE=42703
[db2inst1@ASOMUWFDB401 db2]$ db2 "SELECT TBSP_NAME, DECIMAL(USED_PAGES*PAGESIZE/1024/1024, 10, 2) FROM SYSIBMADM.TBSP_UTILIZATION"
SQL0206N  "USED_PAGES" is not valid in the context where it is used.
SQLSTATE=42703
[db2inst1@ASOMUWFDB401 db2]$ db2 "SELECT DECIMAL(POOL_DATA_L_READS*100/(POOL_DATA_L_READS+POOL_INDEX_L_READS), 10, 2) FROM SYSIBMADM.MON_DB_SUMMARY"
SQL0206N  "POOL_DATA_L_READS" is not valid in the context where it is used.
SQLSTATE=42703
[db2inst1@ASOMUWFDB401 db2]$ db2 "SELECT COUNT(*) FROM SYSIBMADM.LOCKWAITS"
 
1
-----------
SQL1032N  No start database manager command was issued.  SQLSTATE=57019
[db2inst1@ASOMUWFDB401 db2]$ db2 "SELECT COUNT(*) FROM SYSIBMADM.APPLICATIONS WHERE APPLICATION_STATUS='U'"
SQL0206N  "APPLICATION_STATUS" is not valid in the context where it is used.
SQLSTATE=42703
[db2inst1@ASOMUWFDB401 db2]$ db2 "SELECT DECIMAL(AVG(TOTAL_EXECUTION_TIME)/1000, 10, 2) FROM SYSIBMADM.SNAPSQL"
SQL0204N  "SYSIBMADM.SNAPSQL" is an undefined name.  SQLSTATE=42704
[db2inst1@ASOMUWFDB401 db2]$ db2 "SELECT DECIMAL(TOTAL_LOG_USED/LOGFILS/1024/1024, 10, 2) FROM SYSIBMADM.SNAPDB"
SQL0206N  "LOGFILS" is not valid in the context where it is used.
SQLSTATE=42703
[db2inst1@ASOMUWFDB401 db2]$ db2 "SELECT DECIMAL(FLOAT(DENSITY), 10, 2) FROM SYSIBMADM.INDEXES"
SQL0204N  "SYSIBMADM.INDEXES" is an undefined name.  SQLSTATE=42704
[db2inst1@ASOMUWFDB401 db2]$ db2 "SELECT POOL_NAME, DECIMAL(POOL_CUR_BUFFSZ/1024/1024, 10, 2) FROM SYSIBMADM.MON_BP_UTILIZATION"
SQL0206N  "POOL_NAME" is not valid in the context where it is used.
SQLSTATE=42703
[db2inst1@ASOMUWFDB401 db2]$



SELECT DECIMAL(SUM(SIZE)/1024/1024, 10, 2) FROM SYSIBMADM.DB_HISTORY;
SELECT TBSP_NAME, DECIMAL(USED_PAGES/PAGESIZE/1024/1024, 10, 2) FROM SYSIBMADM.TBSP_UTILIZATION

OK - SELECT TBSP_NAME, DECIMAL(USED_PAGES/PAGESIZE/1024/1024, 10, 2) FROM SYSIBMADM.TBSP_UTILIZATION



db2 "SELECT DECIMAL(POOL_DATA_L_READS*100/(POOL_DATA_L_READS+POOL_INDEX_L_READS), 10, 2) FROM SYSIBMADM.MON_DB_SUMMARY"
SQL0206N  "POOL_DATA_L_READS" is not valid in the context where it is used.
SQLSTATE=42703

db2 "SELECT COUNT(*) FROM SYSIBMADM.APPLICATIONS WHERE APPLICATION_STATUS='U'"
SQL0206N  "APPLICATION_STATUS" is not valid in the context where it is used.
SQLSTATE=42703

db2 "SELECT DECIMAL(AVG(TOTAL_EXECUTION_TIME)/1000, 10, 2) FROM SYSIBMADM.SNAPSQL"
SQL0204N  "SYSIBMADM.SNAPSQL" is an undefined name.  SQLSTATE=42704

db2 "SELECT TBSP_NAME, DECIMAL(USED_PAGES/PAGESIZE/1024/1024, 10, 2) FROM SYSIBMADM.TBSP_UTILIZATION"
SQL0206N  "USED_PAGES" is not valid in the context where it is used.
SQLSTATE=42703

{
    zabbix => {
        host    => '192.168.1.100',
        port    => 10051,
        timeout => 30,
    },
    daemon => {
        sleep => 120,
        split_logs => 1,
    },
    db => {
        default => {
            user        => 'zabbix',
            pass        => 'zabbix',
            query_list  => 'query.props.pl',
            sleep       => 30,
            retry_step  => 1,
        },
        list   => [ 'XXXPRD', 'XXXDEV', 'XXXTST' ],
        XXXPRD => {
            dsn        => 'DBI:DB2:dbname=XXXPRD;host=xxxdb11;port=50000;',
            query_list => [qw|query.props.pl extra.query.props.pl|],
            sleep      => 15,
        },
        XXXDEV => {
            dsn  => 'DBI:DB2:dbname=XXXDEV;host=xxxdb01;port=50000;',
            user => 'zabbix',
        },
        XXXTST => {
            dsn        => 'DBI:DB2:dbname=XXXTST;host=xxxdb02;port=50000;',
            retry_step => 2,
        }
    }
}







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
