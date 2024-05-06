#!/bin/bash

# Function to execute a command as the zabbix user
run_as_zabbix() {
    su -s /bin/bash -c "$1" zabbix
}

# Switch to the zabbix user and source the DB2 profile
run_as_zabbix ". /home/db2inst1/sqllib/db2profile"

# DB2 connection details
DB_USER="your_db_username"
DB_PASS="your_db_password"
DB_NAME="pegadb"

# Function to execute DB2 queries
execute_db2_query() {
    run_as_zabbix "db2 connect to $DB_NAME > /dev/null 2>&1 && db2 -x \"$1\""
}

# Function to get db status
get_db_status() {
    execute_db2_query "SELECT DB_STATUS FROM TABLE(MON_GET_DATABASE(-2)) AS T"
}

# Call functions to collect data
db_status=$(get_db_status | sed 's/^[[:space:]]*//')

# Output data in a format readable by Zabbix
echo "DatabaseStatus:$db_status"





#!/bin/bash

# Function to execute the entire script as the Zabbix user
run_as_zabbix() {
    sudo -u zabbix "$@"
}

# Source the DB2 profile
run_as_zabbix ". /home/db2inst1/sqllib/db2profile"

# DB2 connection details
DB_USER="your_db_username"
DB_PASS="your_db_password"
DB_NAME="pegadb"

# Function to execute DB2 queries
execute_db2_query() {
    db2 connect to $DB_NAME > /dev/null 2>&1 && db2 -x "$1"
}

# Function to get db status
get_db_status() {
    execute_db2_query "SELECT DB_STATUS FROM TABLE(MON_GET_DATABASE(-2)) AS T"
}

# Call functions to collect data
db_status=$(get_db_status | sed 's/^[[:space:]]*//')

# Output data in a format readable by Zabbix
echo "DatabaseStatus:$db_

[DB2DataSource]
Description = DB2 Data Source
Driver = IBM DB2 ODBC DRIVER
Server = myserverhostname
Port = 50000
Database = mydatabase
Protocol = TCPIP
Uid = myusername
Pwd = mypassword


"Driver={IBM DB2 ODBC DRIVER};Server=myserverhostname;Port=50000;Database=mydatabase;Protocol=TCPIP;Uid=myusername;Pwd=mypassword;"



