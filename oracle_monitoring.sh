#!/bin/bash
sql=""
sql2=""
export ORACLE_SID='mis'
export ORACLE_HOME='/u01/app/oracle/product/11.2.0/dbhome_1'
export PATH=$ORACLE_HOME/bin:${PATH}
CONNECT='dev/def'
ORACLE_SID=mis

case $1 in

##########################SGA##########################
'total_SGA_used')
        sql="select to_char(sum(bytes)) retvalue from v\$sgastat;"
       ;;
'free_memory_SGA')
       sql="select to_char(bytes) from v\$sgainfo where name='Free SGA Memory Available';"
       ;;
'buffer_cache_size')
        sql="select to_char(bytes) from v\$sgastat where name='buffer_cache';"
        ;;
'large_pool_size')
        sql="select to_char(sum(bytes)) from v\$sgastat where pool='large pool';"
        ;;
'shared_pool_size')
        sql="select to_char(sum(bytes)) from v\$sgastat where pool='shared pool';"
        ;;
'other_SGA')
        sql="select to_char(sum(bytes)) from v\$sgainfo where name IN ('Streams Pool Size', 'Shared IO Pool Size', 'Redo Buffers', 'Java Pool
        Size');"
        ;;
##########################shared pool size##########################
'shared_pool_free')
        sql="select to_char(sum(decode(name, 'free memory', bytes))) from v\$sgastat where pool='shared pool';"
        ;;
'SQLA')
        sql="select to_char(bytes) from v\$sgastat where name='SQLA';"
        ;;
'KGLH0')
        sql="select to_char(bytes) from v\$sgastat where name='KGLH0';"
        ;;
'KGLHD')
        sql="select to_char(bytes) from v\$sgastat where name='KGLHD';"
        ;;
'other_shared_pool')
        sql="select to_char(sum(bytes)) from v\$sgastat where name NOT IN ('SQLA', 'KGLH0', 'free memory', 'KGLHD') and pool='shared pool';"
        ;;
##########################session##########################

'user_sesscount')
        sql="select to_char(count(1)-1) retvalue from v\$session where username is not NULL;"
        ;;
'user_session_active')
        sql="select to_char(count(1)-1) from v\$session where username is not NULL and status='ACTIVE';"
        ;;
'user_session_inactive')
        sql="select to_char(count(1)) from v\$session where username is not NULL and status='INACTIVE';"
        ;;
'system_session')
        sql="select to_char(count(1)) from v\$session where TYPE='BACKGROUND';"
        ;;
'long_session')
      sql="select to_char(max(last_call_et)) from v\$session where status='ACTIVE' and type<>'BACKGROUND';"
;;
##########################shared pool statistics##########################
'library_cache_hit_ratio')
        sql="select sum(pinhits)/sum(pins)*100 from v\$librarycache;"
        ;;
'pin_hit_ratio_SQLAREA_Xmin')
        sql="select round((pinhits.retvalue/pins.retvalue)*100,2) from (select lc.pins-om.value retvalue from v\$librarycache lc, oracle_monitoring
        om WHERE lc.namespace = 'SQL AREA' and
        om.name='sqlarea_pins') pins, (select lc.pinhits-om.value retvalue from v\$librarycache lc, oracle_monitoring om WHERE
        lc.namespace = 'SQL AREA' and om.name='sqlarea_pinhits') pinhits;"
        sql2="update oracle_monitoring set value=(select pins from v\$librarycache where namespace = 'SQL AREA') where name='sqlarea_pins';
        update oracle_monitoring set value=(select pinhits from v\$librarycache where namespace = 'SQL AREA') where name='sqlarea_pinhits';"
        ;;
'get_hit_ratio_SQLAREA_Xmin')
        sql="select round((gethits.retvalue/gets.retvalue)*100,2) from (select lc.gets-om.value retvalue from v\$librarycache lc, oracle_monitoring
        om where lc.namespace='SQL AREA' and om.name='sqlarea_gets')
        gets, (select lc.gethits-om.value retvalue from v\$librarycache lc, oracle_monitoring om where lc.namespace = 'SQL AREA' and
        om.name='sqlarea_getshits') gethits;"
        sql2="update oracle_monitoring set value=(select gets from v\$librarycache where namespace = 'SQL AREA') where name='sqlarea_gets';
        update oracle_monitoring set value=(select gethits from v\$librarycache where namespace = 'SQL AREA') where name='sqlarea_getshits';"
        ;;
'pin_hit_ratio_tab_pr_Xmin')
        sql="select round((pinhits.retvalue/pins.retvalue)*100,2) from (select lc.pins-om.value retvalue from v\$librarycache lc, oracle_monitoring
        om WHERE lc.namespace = 'TABLE/PROCEDURE' and
        om.name='tab_pr_pins') pins,
        (select lc.pinhits-om.value retvalue from v\$librarycache lc, oracle_monitoring om WHERE lc.namespace = 'TABLE/PROCEDURE' and
        om.name='tab_pr_pinhits') pinhits;"
        sql2="update oracle_monitoring set value=(select pins from v\$librarycache where namespace = 'TABLE/PROCEDURE') where name='tab_pr_pins';
        update oracle_monitoring set value=(select pinhits from v\$librarycache where namespace = 'TABLE/PROCEDURE') where name='tab_pr_pinhits';"
        ;;
'get_hit_ratio_tab_pr_Xmin')
        sql="select round((gethits.retvalue/gets.retvalue)*100,2) from
        (select lc.gets-om.value retvalue from v\$librarycache lc, oracle_monitoring om WHERE lc.namespace = 'TABLE/PROCEDURE' and
        om.name='tab_pr_gets') gets,
        (select lc.gethits-om.value retvalue from v\$librarycache lc, oracle_monitoring om WHERE lc.namespace = 'TABLE/PROCEDURE' and
        om.name='tab_pr_gethits') gethits;"
        sql2="update oracle_monitoring set value=(select gets from v\$librarycache where namespace = 'TABLE/PROCEDURE') where name='tab_pr_gets';
        update oracle_monitoring set value=(select gethits from v\$librarycache where namespace = 'TABLE/PROCEDURE') where name='tab_pr_gethits';"
        ;;
'reloads_SQLAREA')
        sql="select to_char(reloads) from v\$librarycache where namespace='SQL AREA';"
        ;;
'reloads_tab_pr')
        sql="select reloads from v\$librarycache where namespace='TABLE/PROCEDURE';"
        ;;
'inv_SQLAREA')
        sql="select invalidations from v\$librarycache where namespace='SQL AREA';"
        ;;
'inv_tab_pr')
        sql="select invalidations from v\$librarycache where namespace='TABLE/PROCEDURE';"
        ;;
##########################parsing statistics##########################
'parse_elapsed_timemodel')
        sql="select to_char(value/1000000) retvalue from v\$sys_time_model where stat_name = 'parse time elapsed';"
        ;;
'hard_parse_elapsed_timemodel')
        sql="select to_char(value/1000000) retvalue from v\$sys_time_model where stat_name = 'hard parse elapsed time';"
        ;;
'parse_time_cpu')
        sql="select to_char(value) retvalue from v\$sysstat where name = 'parse time cpu';"
        ;;
'parse_time_elapsed')
        sql="select to_char(value) retvalue from v\$sysstat where name = 'parse time elapsed';"
        ;;
'parse_count_total')
        sql="select to_char(value) retvalue from v\$sysstat where name = 'parse count (total)';"
        ;;
'parse_count_hard')
        sql="select to_char(value) retvalue from v\$sysstat where name = 'parse count (hard)';"
        ;;
'parse_count_failures')
        sql="select to_char(value) retvalue from v\$sysstat where name = 'parse count (failures)';"
        ;;
'parse_count_describe')
        sql="select to_char(value) retvalue from v\$sysstat where name = 'parse count (describe)';"
        ;;
##########################PGA##########################
'total_PGA_allocated')
        sql="select to_char(value) from v\$pgastat where name='total PGA allocated';"
       ;;
'PGA_workarea_allocated')
        sql="select to_char(value) from v\$pgastat where name='total PGA inuse';"
       ;;
'PGA_over_allocation_count')
        sql="select to_char(value) from v\$pgastat where name='over allocation count';"
       ;;
'pga_hit')
        sql="select to_char(value) from v\$pgastat where name='cache hit percentage';"
        ;;
'pga_hit_Xmin')
        sql="select BP.retvalue*100/(BP.retvalue+EBP.retvalue) retvalue from
        (select (ps.value - om.value) retvalue from V\$pgastat ps, oracle_monitoring om WHERE ps.NAME = 'bytes processed'
        and om.name='bytes processed' ) BP,
        (select (ps.value - om.value) retvalue from V\$pgastat ps, oracle_monitoring om WHERE ps.NAME = 'extra bytes read/written' and
        om.name='extra bytes read/written' ) EBP;"
        sql2="update oracle_monitoring set value=(select value from V\$pgastat where name='bytes processed' ) where name='bytes processed';
        update oracle_monitoring set value=(select value from V\$pgastat where name='extra bytes read/written' ) where name=
        'extra bytes read/written';"
        ;;
##########################Buffer cache##########################
'buffer_cache_hit')
        sql="SELECT ROUND((1-(phy.value / (cur.value + con.value)))*100,2) FROM v\$sysstat cur, v\$sysstat con, v\$sysstat phy WHERE cur.name =
        'db block gets' AND con.name = 'consistent gets' AND phy.name ='physical reads';"
        ;;
'buffer_cache_hit_Xmin')
        sql="SELECT ROUND((1-(phy.retvalue / (cur.retvalue + con.retvalue)))*100,2) FROM
        (select ss.value - om.value retvalue from v\$sysstat ss, oracle_monitoring om WHERE ss.NAME = 'db block gets' and om.name='db block gets' )
         cur,
        (select ss.value - om.value retvalue from v\$sysstat ss, oracle_monitoring om WHERE ss.NAME = 'consistent gets'
        and om.name='consistent gets' ) con,
        (select ss.value - om.value retvalue from v\$sysstat ss, oracle_monitoring om WHERE ss.NAME = 'physical reads' and om.name='physical reads'
         ) phy;"
        sql2="update oracle_monitoring set value=(select value from v\$sysstat where name='db block gets' ) where name='db block gets';
        update oracle_monitoring set value=(select value from v\$sysstat where name='consistent gets' ) where name='consistent gets';
        update oracle_monitoring set value=(select value from v\$sysstat where name='physical reads' ) where name='physical reads';"
        ;;
'background_checkpoints_completed')
        sql="select to_char(value) from v\$sysstat where name = 'background checkpoints completed';"
        ;;
'background_checkpoints_started')
        sql="select to_char(value) from v\$sysstat where name = 'background checkpoints started';"
        ;;
'DBWR_checkpoint_buffers_written')
        sql="select to_char(value) from v\$sysstat where name = 'DBWR checkpoint buffers written';"
        ;;
'DBWR_checkpoints')
        sql="select to_char(value) from v\$sysstat where name = 'DBWR checkpoints';"
        ;;
##########################redo statistic##########################
'redosize')
        sql="select value  from v\$sysstat where name='redo size';"
       ;;
'redo_log_switch')
        sql="select max(sequence#) from v\$log;"
       ;;
'redo_log_sync')
      sql="select to_char(value) from v\$sysstat where name = 'redo synch time';"
        ;;
'redo_log_sync_usec')
      sql="select to_char(value) from v\$sysstat where name = 'redo synch time (usec)';"
        ;;
##########################wait statistic##########################
'dbscattread')
        sql="select round(time_waited_micro/1000000,2) retvalue from v\$system_event where event='db file scattered read';"
        ;;
'dbseqread')
        sql="select round(time_waited_micro/1000000,2) retvalue from v\$system_event where event='db file sequential read';"
        ;;
'wait_direct_path_read')
        sql="select to_char(round(time_waited_micro/1000000,0)) from V\$system_event where event='direct path read';"
        ;;
'wait_latch_sum')
        sql="select to_char(round(sum(time_waited_micro)/1000000, 0)) from V\$system_event where event like '%latch%';"
        ;;
'wait_db_file_single_write')
        sql="select to_char(round(time_waited_micro/1000000,0)) from V\$system_event where event = 'db file single write';"
        ;;
'wait_db_file_parallel_write')
        sql="select to_char(round(time_waited_micro/1000000,0)) from V\$system_event where event = 'db file parallel write';"
        ;;
'wait_db_file_parallel_read')
        sql="select  to_char(round(time_waited_micro/1000000,0)) from V\$system_event where event = 'db file parallel read';"
        ;;
'wait_control_file_IO')
        sql="select to_char(round(sum(time_waited_micro/1000000 ),0)) from V\$system_event where event like '%control file%';"
        ;;
'wait_logfile_IO')
        sql="select to_char(round(sum(time_waited_micro/1000000 ),0)) from V\$system_event where event like '%log%';"
        ;;
'app_wait_time')
        sql="select round(ss.value/1000000,2) from v\$sysstat ss WHERE ss.NAME = 'application wait time';"
        ;;
#######################critical alert#######################
'tablespace_alert')
	sql="select coalesce(min(MYFREE),0) from (
        select a.tablespace_name, round(((maxbytes - (a.bytes_alloc - b.bytes_free))/1048576), 0) as myfree
        from (select  f.tablespace_name, sum(f.bytes) bytes_alloc, sum(decode(f.autoextensible, 'YES',f.maxbytes,
        'NO', f.bytes)) maxbytes from dba_data_files f group by tablespace_name) a,
        (select f.tablespace_name, sum(f.bytes)  bytes_free from dba_free_space f  group by tablespace_name) b
        where a.tablespace_name = b.tablespace_name (+)) where myfree<15000;"
;;
#        sql="select count(*) from (
#        select a.tablespace_name, round(((maxbytes - (a.bytes_alloc - b.bytes_free))/1048576), 0) as myfree
#        from (select  f.tablespace_name, sum(f.bytes) bytes_alloc, sum(decode(f.autoextensible, 'YES',f.maxbytes,
#	 'NO', f.bytes)) maxbytes from dba_data_files f group by tablespace_name) a,
#        (select f.tablespace_name, sum(f.bytes)  bytes_free from dba_free_space f  group by tablespace_name) b
#        where a.tablespace_name = b.tablespace_name (+)) where myfree<5000;"
#        ;;
#        sql="select count(*) from (select  round((round((a.bytes_alloc - b.bytes_free) / 1024 / 1024, 3))/round(maxbytes/1048576,3)*100,2) used
#       from ( select  f.tablespace_name, sum(f.bytes) bytes_alloc, sum
#        (decode(f.autoextensible, 'YES',f.maxbytes,'NO', f.bytes)) maxbytes from dba_data_files f group by tablespace_name) a, (select
#       f.tablespace_name, sum(f.bytes)  bytes_free from dba_free_space f  group
#        by tablespace_name) b where a.tablespace_name = b.tablespace_name (+)) retvalue where used>85;"
#       ;;
'DB_block_corruption')
        sql="SELECT count(*) FROM V\$DATABASE_BLOCK_CORRUPTION;"
        ;;
'fra_used')
        sql="SELECT ROUND((SPACE_USED - SPACE_RECLAIMABLE)/SPACE_LIMIT * 100, 2) AS Used_proc FROM V\$RECOVERY_FILE_DEST;"
        ;;
'shared_server_util%')
        sql="select  ROUND(((select count(1) from v\$shared_server where status='EXEC')/(select count(1) from v\$shared_server)*100), 0) from dual;"
        ;;
'backup_check')
        sql="select status from v\$rman_status where to_date(START_TIME, 'dd.mm.yyyy') = to_date(sysdate, 'dd.mm.yyyy');"
        ;;
#######################system statistics#######################
'DB_time')
        sql="select to_char(round(value/1000000,0)) from v\$sys_time_model where stat_name='DB time';"
        ;;
'DB_CPU')
        sql="select to_char(round(value/1000000,0)) from v\$sys_time_model where stat_name='DB CPU';"
        ;;
'DB_logical_size')
        sql="select
        to_char(sum(a.bytes_alloc - b.bytes_free))  used from
        (select  f.tablespace_name, sum(f.bytes) bytes_alloc from dba_data_files f where tablespace_name<>'UNDOTBS1' group by tablespace_name) a,
        (select  f.tablespace_name, sum(f.bytes)  bytes_free from dba_free_space f where tablespace_name<>'UNDOTBS1'  group by tablespace_name) b
        where a.tablespace_name = b.tablespace_name (+);"
       ;;
'block_changes')
        sql="select to_char(value) from v\$sysstat where name='db block changes';"
        ;;
'jobs_running')
        sql="select cnt1 + cnt2 as mycnt from (select count(*) as cnt1 from dba_scheduler_running_jobs), (select count(*) as cnt2 from
      dba_jobs_running);"
       ;;
'mis_jobs')
       sql="select count(1) from dba_jobs t where instr(upper(t.what), 'D_PKG_USER_JOBS.JOB_EXECUTE') != 0;"
       ;;
'broken_jobs')
       sql="select count(1) from sys.DBA_JOBS t where t.BROKEN = 'Y';"
       ;;
'sga_resize_ops')
        sql="select count(*) from v\$sga_resize_ops where to_date(START_TIME, 'dd.mm.yyyy')=to_date(sysdate, 'dd.mm.yyyy');"
        ;;
'process_count')
        sql="select value from v\$pgastat where name='process count';"
        ;;
'temp_tbs_used')
        sql="select NVL(sum(blocks)*8192, 0) bytes from V\$TEMPSEG_USAGE;"
        ;;
'pCPU_pELP')
        sql="select round(a.value/b.value*100, 2) from v\$sysstat a, v\$sysstat b where a.name='parse time cpu' and b.name='parse time elapsed';"
       ;;
'pCPU_pELP_Xmin')
        sql="select round((ptc.retvalue/pte.retvalue)*100, 2) from
        (select ss.value-om.value retvalue from v\$sysstat ss, oracle_monitoring om where ss.NAME='parse time cpu' and om.name='parse time cpu') ptc,
        (select ss.value-om.value retvalue from v\$sysstat ss, oracle_monitoring om where ss.NAME='parse time elapsed'
        and om.name='parse time elapsed') pte;"
        sql2="update oracle_monitoring set value=(select value from v\$sysstat where name='parse time cpu') where name='parse time cpu';
        update oracle_monitoring set value=(select value from v\$sysstat where name='parse time elapsed') where name='parse time elapsed';"
       ;;
'exec_to_parse')
       sql="select round(100*(1-a.VALUE/b.VALUE)) from v\$sys_time_model a, v\$sys_time_model b where a.stat_name='parse time elapsed' and
       b.STAT_NAME='sql execute elapsed time';"
       ;;
'exec_to_parse_Xmin')
       sql="select round(100*(1-pte.retvalue/eet.retvalue)) from
       (select stm.value-om.value retvalue from v\$sys_time_model stm, oracle_monitoring om where stm.stat_name='parse time elapsed' and
        om.name='parse time elapsed2') pte,
       (select stm.value-om.value retvalue from v\$sys_time_model stm, oracle_monitoring om where stm.stat_name='sql execute elapsed time' and
        om.name='sql execute elapsed time') eet;"
       sql2="update oracle_monitoring set value=(select stm.value from v\$sys_time_model stm where stm.stat_name='parse time elapsed') where
        name='parse time elapsed2';
       update oracle_monitoring set value=(select stm.value from v\$sys_time_model stm where stm.stat_name='sql execute elapsed time') where
        name='sql execute elapsed time';"
      ;;
'concur_wait_time')
      sql="select to_char(round(ss.value/1000000, 2)) from v\$sysstat ss WHERE ss.NAME = 'concurrency wait time';"
     ;;
'logons_cumulative')
      sql="select to_char(value) from v\$sysstat where name = 'logons cumulative';"
        ;;
'session_logical_reads')
      sql="select to_char(value) from v\$sysstat where name = 'session logical reads';"
        ;;
'logical_read_bytes_from_cache')
      sql="select to_char(value) from v\$sysstat where name = 'logical read bytes from cache';"
        ;;
'open_cursor')
        sql="select count(1) from v\$open_cursor where cursor_type='OPEN';"
        ;;
'user_commit')
      sql="select to_char(value) from v\$sysstat where name = 'user commits';"
;;
'user_rollback')
      sql="select to_char(value) from v\$sysstat where name = 'user rollbacks';"
;;
'execute_count')
      sql="select to_char(value) from v\$sysstat where name ='execute count';"
;;
'execute_elapsed_time')
      sql="select to_char(value) from v\$sys_time_model where stat_name = 'sql execute elapsed time';"
;;
'invalid_packages')
        sql="select to_char(count(*)) from dba_objects where status<>'VALID' and object_type not in ('SYNONYM', 'JAVA CLASS');"
;;
'sort_memory')
        sql="select to_char(value) from v\$sysstat where name='sorts (memory)';"
;;
'sort_disk')
        sql="select to_char(value) from v\$sysstat where name='sorts (disk)';"
;;
'logical_reads')
    sql="select to_char(sum(value)) from v\$sysstat where name='consistent gets' or name='db block gets';"
;;
#######################IO statistics#######################
'phio_datafile_reads_direct')
        sql="select to_char(value) from v\$sysstat where name='physical reads direct';"
        ;;
'phio_datafile_writes_direct')
        sql="select to_char(value) from v\$sysstat where name='physical writes direct';"
        ;;
'physical_reads')
      sql="select to_char(value) from v\$sysstat where name='physical read total bytes';"
;;
'physical_writes')
      sql="select to_char(value) from v\$sysstat where name='physical write total bytes';"
;;
'physical_read_IO_requests')
      sql="select to_char(value) from v\$sysstat where name='physical read IO requests';"
 ;;
 'physical_read_total_IO_requests')
    sql="select to_char(value) from v\$sysstat where name='physical read total IO requests';"
;;
'physical_read_total_multi_block_requests')
      sql="select to_char(value) from v\$sysstat where name='physical read total multi block requests';"
 ;;
'physical_write_IO_requests')
    sql="select to_char(value) from v\$sysstat where name='physical write IO requests';"
;;
'physical_write_total_IO_requests')
  sql="select to_char(value) from v\$sysstat where name='physical write total IO requests';"
      ;;
 'physical_write_total_multi_block_requests')
sql="select to_char(value) from v\$sysstat where name='physical write total multi block requests';"
;;
#######################network statistics#######################
'wait_TCP_SOCKET_KGAS')
        sql="select to_char(round(time_waited_micro/1000000,0)) from V\$system_event where event ='TCP Socket (KGAS)';"
       ;;
#######################latch statistics#######################
'latch_row_cache_objects')
      sql="select to_char(wait_time) from v\$latch where name='row cache objects';"
;;
'latch_shared_pool')
      sql="select to_char(wait_time) from v\$latch where name='shared pool';"
;;
'latch_virtual_circuit_buffers')
      sql="select to_char(wait_time) from v\$latch where name='virtual circuit buffers';"
;;
'latch_cache_buffers_chains')
      sql="select to_char(wait_time) from v\$latch where name='cache buffers chains';"
;;
'latch_virtual_circuit_queues')
      sql="select to_char(wait_time) from v\$latch where name='virtual circuit queues';"
;;

#######################undo#######################

'undo_unexpired')
    sql="SELECT to_char(NVL(SUM(BYTES),0)) SUM_BYTES FROM DBA_UNDO_EXTENTS where status='UNEXPIRED';"
;;
'undo_expired')
    sql="SELECT to_char(NVL(SUM(BYTES),0)) SUM_BYTES FROM DBA_UNDO_EXTENTS where status='EXPIRED';"
;;
'undo_active')
    sql="SELECT to_char(NVL(SUM(BYTES),0)) SUM_BYTES FROM DBA_UNDO_EXTENTS where status='ACTIVE';"
;;
'undo_size')
    sql="SELECT to_char(SUM(A.BYTES)) UNDO_SIZE FROM DBA_TABLESPACES C JOIN V\$TABLESPACE B ON B.NAME = C.TABLESPACE_NAME JOIN V\$DATAFILE A ON A.TS# = B.TS# WHERE C.CONTENTS = 'UNDO' AND C.STATUS = 'ONLINE';"
;;
'undo_blocks')
    sql="select to_char(NVL(sum(undoblks),0)) FROM  V\$UNDOSTAT;"

esac
if [ "$sql" != "" ]; then
RES=$(
$ORACLE_HOME/bin/sqlplus -s ${CONNECT}@${ORACLE_SID}  << END
set feedback off heading off
alter session set NLS_NUMERIC_CHARACTERS='.,';
$sql
$sql2
commit;
END
)

if [ $1 = 'backup_check' ] && [ -z "$RES" ]; then
echo 1
elif [ $1 = 'backup_check' ] && [ -n "$RES" ]; then
echo $RES | tr ' ' '\n' | awk 'BEGIN {A=0} echo $1 {if(($1!="COMPLETED") && ($1!="RUNNING")){A=1}} END {print A;}'
else
echo $RES  # |egrep -o '[0-9]*\.*[0-9]+$'
fi
fi

