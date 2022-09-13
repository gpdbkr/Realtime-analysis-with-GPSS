PERF=`psql -Atc "select cnt
	 , to_char(start_tm, 'yyyy-mm-dd hh24:mi:ss') start_tm
	 , to_char(end_tm,   'yyyy-mm-dd hh24:mi:ss') end_tm
	 , end_tm-start_tm elapsed_tm
	 , coalesce(trunc(cnt/ case when extract ('epoch' from (end_tm-start_tm)) = 0 then null else  extract ('epoch' from (end_tm-start_tm))  end ), 0) tps
from (
select min(last_update) start_tm
     , max(last_update) end_tm
     , count(*) cnt
from   weblog.weblog_data
) a"`
echo "1"
STAGE=`psql -Atc "select count(*) from weblog.stag_weblog_data"`
echo "2"

#LOGTOTAL=`psql -Atc "select count(*) from weblog.weblog_data"`
SUMMARY=`psql -Atc "select count(*) from weblog.weblog_sum_user_dd"`
echo "3"

LOGTOTAL=`echo $PERF | awk -F"|" '{print $1}'`
STM=`echo $PERF | awk -F"|" '{print $2}'`
FTM=`echo $PERF | awk -F"|" '{print $3}'`
ETM=`echo $PERF | awk -F"|" '{print $4}'`
TPS=`echo $PERF | awk -F"|" '{print $5}'`


echo
date +'%Y-%m-%d %H:%M:%S'
echo "==================================="
echo "Number of table rows"
echo "-----------------------------------"
printf "     STAGING : %'14d\n" $STAGE
printf "  PROCESSING : %'14d\n" $LOGTOTAL
printf "FINAL RESULT : %'14d\n" $SUMMARY
echo "==================================="
echo "Performance Summary"
echo "-----------------------------------"
printf "         TPS : %'d\n" $TPS
printf "  TOTAL ROWS : %'d\n" $LOGTOTAL
printf "ELAPSED TIME : %s\n" $ETM
printf "   BEGINNING : %s %s\n" $STM
printf "     LASTEST : %s %s\n" $FTM
echo "==================================="
