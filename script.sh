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
        echo "Usage: $0 [database_size|tablespaces_usage|buffer_pool_hit_ratio|lock_waits|active_connections|query_execution_time|log_file_usage|index_fragmentation|buffer_pool_usage]"
        ;;
esac
