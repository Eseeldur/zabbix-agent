sql=""
sql2=""
export ORACLE_SID='mis'
export ORACLE_HOME='/u01/app/oracle/product/11.2.0/dbhome_1'
export PATH=$ORACLE_HOME/bin:${PATH}
CONNECT='dev/def'
ORACLE_SID=mis

###########################ASH########################
case $1 in

'CPU')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and session_state='ON CPU';"
;;
'User I/O')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='User I/O';"
;;
'System I/O')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='System I/O';"
;;
'Commit')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='Commit';"
;;
'Concurrency')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='Concurrency';"
;;
'Administrative')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='Administrative';"
;;
'Application')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='Application';"
;;
'Cluster')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='Cluster';"
;;
'Configuration')
    sql="select NVL(round(COUNT(*)/60, 2), 0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='Configuration';"
;;
'Idle')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='Idle';"
;;
'Network')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='Network';"
;;
'Other')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='Other' group by TRUNC(sample_time,'MI'), wait_class, session_state;"
;;
'Queue')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='Queue' group by TRUNC(sample_time,'MI'), wait_class, session_state;"
;;
'Scheduler')
    sql="select NVL(round(COUNT(*)/60, 2),0) avg_act_ses from v\$active_session_history WHERE trunc(sample_time+0,'MI')=trunc(systimestamp-1/1440,'MI') and wait_class='Scheduler' group by TRUNC(sample_time,'MI'), wait_class, session_state;"
esac

RES=$($ORACLE_HOME/bin/sqlplus -s ${CONNECT}@${ORACLE_SID}  << END
set feedback off heading off 
alter session set NLS_NUMERIC_CHARACTERS='.,';
$sql
END
)
echo $RES
