---Debezium 
ALTER SESSION SET CONTAINER = CDB$ROOT;
alter system set db_recovery_file_dest_size = 4G;
--alter system set db_recovery_file_dest = '/opt/oracle/oradata/recovery_area' scope=spfile;
--alter system set enable_goldengate_replication=true;
shutdown immediate
startup mount
alter database archivelog;
alter database open;
-- Should show "Database log mode: Archive Mode"
archive log list