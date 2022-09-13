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

gpsspoc             : Greenplum 사이드에서 테스트 스크립트
check.sh            : GPSS 수행되는 동안 TPS  측정
cnt.sql             : 건수 측정
gpss_daemon.sh      : gpss 데몬 Start 스크립트 (경로 확인 필요)
job_list.sh         : gpss job list 확인
job_remove.sh       : gpss job 삭제
job_start.sh        : gpss job 시작
job_stop.sh         : gpss job 중지
job_submit.sh       : gpss job submit 
weblog.stag_weblog_data.yaml : kafka의 토픽을 Greenplum Table 컬럼 맵핑 및 데이터 가공 호출하는 설정 파일 

kafka: Kafka 사이드에서 테스트 스크립트
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

