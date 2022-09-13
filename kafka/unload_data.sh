psql -h mdw -p 5432 -d dev -c "\copy (select uqid, userid, eid, log_tm, peid, dt, ip from weblog.weblog_data order by log_tm) to '/data1/kafka/kafka_data/weblog_data.csv' with CSV"
