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
