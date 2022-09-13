## Greenplum Stream Server(GPSS)를 이용한 웹로그 실시간 분석 예제입니다.

### 웹로그 실시간 분석 데모셋 설명
```
1. Kafka에서 스트림 데이터 적재
2. Kafka의 스트림 데이터를 GPSS를 이용하여 Greenplum으로 데이터 적재시 Raw데이터는 단순 적재하고, 실시간 스트림 데이터는 사용자별로 가공하여 적재
   - GPSS에서 1초 간격으로 데이터를 Ingestion할 때, 변환 가공하여 적재
   - GPSS에서 polling 시간은 Default는 1초이지만, 0.1초까지 설정 변경 가능
   - 데이터 트랜잭션은 Data Ingestion과 변환까지 하나의 트랜잭션으로 묶음.
3. Data Flow
   Kafka -> GPSS -> 스트림 데이터를 Greenplum의 웹로그 테이블에 적재
                 -> 스트림 데이터를 Greenplum에서 가공하여 테이블에 적재(weblog.sp_weblog_sum_user_dd 프로시저에서 가공)     
```

### 파일 및 경로 설명
```
README.md
1.gpss_kafka_install.txt : gpss & kafka 설치 및 연동 테스트 스크립트
2.weblog_realtime_analysis_ddl.sql : 웹로그 샘플 데이터 생성을 위한 DDL 스크립트
3.weblog_data_generation_dml.sql   : 웹로그 샘플 데이터 생성을 위한 DML 스크립트

gpsspoc             : Greenplum 사이드에서 테스트 스크립트(Greenplum mdw 서버)
check.sh            : GPSS 수행되는 동안 TPS  측정
truncate_table.sql  : 테이블 truncate 스크립트
gpss_daemon.sh      : gpss 데몬 Start 스크립트 (경로 확인 필요)
job_list.sh         : gpss job list 확인
job_remove.sh       : gpss job 삭제
job_start.sh        : gpss job 시작
job_stop.sh         : gpss job 중지
job_submit.sh       : gpss job submit 
weblog.stag_weblog_data.yaml : kafka의 토픽을 Greenplum Table 컬럼 맵핑 및 데이터 가공 호출하는 설정 파일 

kafka: Kafka 사이드에서 테스트 스크립트(kafka 서버)
kafka_data          : kafka에 메시지를 넣기 위한 데이터 폴더
kafka_start.sh      : kafka start 
kafka_stop.sh       : kafka stop
kafka_topic_create.sh : kafka 토픽 생성
kafka_topic_delete.sh : kafka 토픽 삭제
kafka_topic_list.sh.  : kafka 토픽 리스트 확인
kafka_topic_load_all.sh : kafka 토픽에 메시지 적재 - 파일을 계속적으로 로딩 함(경로 확인 필요)
kafka_topic_show.sh   : kafka 토픽 메시지 확인
unload_data.sh        : Greenplum의 weblog.weblog_data 테이블의 데이터를 unloading(kafka에 psql이 설치되지 않았을 경우, Greenplum에서 unload 필요, 경로 확인 필요)
unload_data_split.sh  : weblog.weblog_data 테이블 unloading된 파일을 50000건씩 파일을 쪼갬 (경로 확인 필욧)
zk_start.sh           : zoo keeper start 
zk_stop.sh            : zoo keeper stop 
```

### 수행 방법
```
1. gpss 설치, kafka 설치 및 kafka - gpss 연동 테스트 수행
   - 1.gpss_kafka_install.txt 스크립트 참조

2. 웹로그 샘플 데이터 생성을 위한 DDL 수행 (Greenplum 마스터 노드에서 수행)
   $ psql -ef weblog_realtime_analysis_ddl.sql   

3. 웹로그 샘플 데이터 생성 (Greenplum 마스터 노드에서 수행)
   $ psql -ef weblog_data_generation_dml.sql 

4. kafka에 데이터 적재를 위한 데이터 파일 생성
   - 테이블에 적재된 데이터 unloading 및 파일 split 수행 (Kafka 서버에서 수행)
   $ cd kafka/
   $ sh unload_data.sh 
   $ sh unload_data_split.sh
   $ cd kafka_data/
   $ ls | head
log_aa
log_ab
...
log_zbxx
weblog_data.csv

5. kafka에서 토픽 생성(Kafka 서버에서 수행)
[gpadmin@sdw2 kafka]$ ./kafka_topic_list.sh
__consumer_offsets
[gpadmin@sdw2 kafka]$ ./kafka_topic_create.sh
[gpadmin@sdw2 kafka]$ ./kafka_topic_list.sh
__consumer_offsets
weblog.stag_weblog_data
[gpadmin@sdw2 kafka]$

6. Greenplum에서 기존 데이터 정리 (Greenplum 마스터에서 수행)
   $ cd gpsspoc
   $ psql -ef truncate_table.sql 

7. gpss 수행 (Greenplum 마스터에서 수행)

[gpadmin@mdw gpsspoc]$ ./job_list.sh 
JobName                             JobID                               GPHost          GPPort  DataBase        Schema          Table                           Topic           Status

[gpadmin@mdw gpsspoc]$ ./job_submit.sh
20220913 01:21:05 [INFO] JobID: 5ea72e6f86009c94a17c297ae1efa70a,JobName: weblog.stag_weblog_data

[gpadmin@mdw gpsspoc]$ ./job_start.sh
20220913 01:21:14 [INFO] Job weblog.stag_weblog_data is started

[gpadmin@mdw gpsspoc]$
[gpadmin@mdw gpsspoc]$ ./job_list.sh
JobName                             JobID                               GPHost          GPPort  DataBase        Schema          Table                           Topic           Status
weblog.stag_weblog_data             5ea72e6f86009c94a17c297ae1efa70a    mdw             6432    dev             weblog          stag_weblog_data                weblog.stag_weblog_dataJOB_RUNNING
[gpadmin@mdw gpsspoc]$

8. kafka에서 토픽에 데이터 적재 (Kafka 서버에서 수행)
[gpadmin@sdw2 kafka]$ ./kafka_topic_list.sh
################### Beginning: load to kafka
################### File Count: 1
################### loading file name: log_aa

9. 데이터 적재 현황 확인 (Greenplum 마스터에서 수행)
[gpadmin@mdw gpsspoc]$ ./check.sh
[gpadmin@mdw gpsspoc]$ while true; do date; ./check.sh ; sleep 5;done
2022. 09. 13. (화) 01:28:29 EDT
1
2
3

2022-09-13 01:28:30
===================================
Number of table rows
-----------------------------------
     STAGING :              0
  PROCESSING :      3,400,000
FINAL RESULT :         94,263
===================================
Performance Summary
-----------------------------------
         TPS : 21,706
  TOTAL ROWS : 3,400,000
ELAPSED TIME : 00:02:36.635117
   BEGINNING : 2022-09-13 01:25:51
     LASTEST : 2022-09-13 01:28:27
===================================

10. Greenplum에서 데이터 적재 현황 확인 (Greenplum에 접속 후 확인)

set optimizer=off;
set random_page_cost=0;
set enable_nestloop=on;


select * from weblog.stag_weblog_data
limit 10;

select * from weblog.weblog_data
limit 10;

select * from weblog.weblog_sum_user_dd
where userid = '010681231'      -- 생성된 데이터에서 확인 후 필터링
limit 10;

-- 가공된 데이터로 부터 사용자 이력 추출
select log_dt
      ,userid
      ,log_tm
      ,dd.eid
      ,dt
      ,d1||':'||coalesce (d2, '')||':'||coalesce (d3, '') page
 from (
      select log_dt, userid
            ,unnest(log_tm_arr) log_tm
            ,unnest(eid_arr) eid
            ,unnest(dt_arr) dt
        from weblog.weblog_sum_user_dd
       where userid = '010681231'  -- 생성된 데이터에서 확인 후 필터링   
      ) dd,
      weblog.weblog_menu mn
where dd.eid = mn.eid
order by 1,2,3
;

--Raw 테이블로 부터 집계성 데이터 추출 
SELECT to_char(log_tm, 'yyyymmdd')  dt 
       , b.d1, b.d2, b.d3
       , COUNT(DISTINCT userid) lv
       , COUNT(*) pv
       , SUM(dt) dt
FROM   weblog.weblog_data a
       , weblog.weblog_menu b
WHERE  a.eid = b.eid
GROUP BY to_char(log_tm, 'yyyymmdd') 
       , b.d1, b.d2, b.d3
order by 1, 2, 3, 4, 5
;


```