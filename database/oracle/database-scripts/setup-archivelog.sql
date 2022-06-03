--- Debezium needs the archive and supplemental log features
ALTER SESSION SET CONTAINER = CDB$ROOT;

ALTER SYSTEM SET db_recovery_file_dest_size = 4G;

--alter system set db_recovery_file_dest = '/opt/oracle/oradata/recovery_area' scope=spfile;
--alter system set enable_goldengate_replication=true;

--Enabling Archive log
SHUTDOWN IMMEDIATE
STARTUP MOUNT
ALTER DATABASE archivelog;
ALTER DATABASE OPEN;

-- If the Archive log configuration is successful, the following instruction's 
-- output should show "Database log mode: Archive Mode"
ARCHIVE LOG LIST

-- Enablig supplemental log in the CDB$ROOT container
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;

-- Creating a tablespace for logminer for the CDB$ROOT container

CREATE TABLESPACE logminer_tbs DATAFILE '/opt/oracle/oradata/ORAPOC/logminer_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

-- Creating a tablespace for logminer on the PDB container
-- This needs to be done before the grants to the Debezium user are executed;
-- otherwise, the grants will fail

ALTER SESSION SET CONTAINER = ORAPOCPDB;

CREATE TABLESPACE logminer_tbs DATAFILE '/opt/oracle/oradata/ORAPOC/ORAPOCPDB/logminer_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;


-- Adding supplemental log data for all columns of the table Debezium will be
-- inspecting

ALTER TABLE ot.keys ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;


-- The Debezium user needs to be created in the CDB$ROOT container
ALTER SESSION SET CONTAINER = CDB$ROOT;

-- Creating a user for Debezium and granting necessary permissions for the connector's
-- operation

CREATE USER c##dbzuser IDENTIFIED BY dbz DEFAULT TABLESPACE logminer_tbs QUOTA UNLIMITED ON logminer_tbs CONTAINER=ALL;

GRANT CREATE SESSION TO c##dbzuser CONTAINER=ALL;

GRANT SET CONTAINER TO c##dbzuser CONTAINER=ALL;

GRANT SELECT ON V_$DATABASE to c##dbzuser CONTAINER=ALL;

GRANT FLASHBACK ANY TABLE TO c##dbzuser CONTAINER=ALL;

GRANT SELECT ANY TABLE TO c##dbzuser CONTAINER=ALL;

GRANT SELECT_CATALOG_ROLE TO c##dbzuser CONTAINER=ALL;

GRANT EXECUTE_CATALOG_ROLE TO c##dbzuser CONTAINER=ALL;

GRANT SELECT ANY TRANSACTION TO c##dbzuser CONTAINER=ALL;

GRANT LOGMINING TO c##dbzuser CONTAINER=ALL;

GRANT CREATE TABLE TO c##dbzuser CONTAINER=ALL;

GRANT LOCK ANY TABLE TO c##dbzuser CONTAINER=ALL;

GRANT ALTER ANY TABLE TO c##dbzuser CONTAINER=ALL;

GRANT CREATE SEQUENCE TO c##dbzuser CONTAINER=ALL;

GRANT EXECUTE ON DBMS_LOGMNR TO c##dbzuser CONTAINER=ALL;

GRANT EXECUTE ON DBMS_LOGMNR_D TO c##dbzuser CONTAINER=ALL;

GRANT SELECT ON V_$LOG TO c##dbzuser CONTAINER=ALL;

GRANT SELECT ON V_$LOG_HISTORY TO c##dbzuser CONTAINER=ALL;

GRANT SELECT ON V_$LOGMNR_LOGS TO c##dbzuser CONTAINER=ALL;

GRANT SELECT ON V_$LOGMNR_CONTENTS TO c##dbzuser CONTAINER=ALL;

GRANT SELECT ON V_$LOGMNR_PARAMETERS TO c##dbzuser CONTAINER=ALL;

GRANT SELECT ON V_$LOGFILE TO c##dbzuser CONTAINER=ALL;

GRANT SELECT ON V_$ARCHIVED_LOG TO c##dbzuser CONTAINER=ALL;

GRANT SELECT ON V_$ARCHIVE_DEST_STATUS TO c##dbzuser CONTAINER=ALL;

