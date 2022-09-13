select 'weblog.stag_weblog_data' tb_nm, count(*) from weblog.stag_weblog_data;
select 'weblog.weblog_data' tb_nm, cnt
         , to_char(start_tm, 'yyyy-mm-dd hh24:mi:ss') start_tm
         , to_char(end_tm,   'yyyy-mm-dd hh24:mi:ss') end_tm
         , end_tm-start_tm elapsed_tm
         , coalesce(trunc(cnt/ case when extract ('epoch' from (end_tm-start_tm)) = 0 then null else  extract ('epoch' from (end_tm-start_tm))  end ), 0) tps
from (
select min(last_update) start_tm
     , max(last_update) end_tm
     , count(*) cnt
from   weblog.weblog_data
) a ;
select 'weblog.weblog_sum_user_dd' tb_nm, count(*) from weblog.weblog_sum_user_dd;
