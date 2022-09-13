create schema weblog;

--Weblog 메뉴
--drop table weblog.weblog_menu;
CREATE TABLE weblog.weblog_menu
(
   eid int,         --메뉴 ID, 페이지 ID(url를 id으로 관리)
   d1  VARCHAR(50),   --depth1 명(카테고리 대) 
   d2  VARCHAR(50),   --depth2 명(카테고리 중)
   d3  VARCHAR(50)    --depth3 명(카테고리 소)
)
distributed BY (eid);

--Weblog 샘플 데이터 (증분 전) 
--Drop TABLE weblog.weblog_data_base;
CREATE TABLE weblog.weblog_data_base
(
   UqID VARCHAR,    -- userid 암호화
   userid VARCHAR,  -- userid
   eid    int,           --메뉴 ID
   log_tm timestamp,     --로그 적재시각
   peid   int,           --이전 메뉴 ID
   dt     int,           --체류 시간 (초)
   ip     VARCHAR,  --IP 
   last_update timestamp
)
distributed by (userid)
;

--Weblog 적재 테이블 (증분 후)
--drop TABLE weblog.weblog_data;
CREATE TABLE weblog.weblog_data
(
   UqID VARCHAR,    -- userid 암호화
   userid VARCHAR,  -- userid
   eid    int,           --메뉴 ID
   log_tm timestamp,     --로그 적재시각
   peid   int,           --이전 메뉴 ID
   dt     int,           --체류 시간 (초)
   ip     VARCHAR,  --IP 
   last_update timestamp
)
with (appendonly=true, compresslevel=1, compresstype=zstd)
distributed by (userid)
partition by range(log_tm)
(
    partition p20220831 start('2022-08-31'::timestamp) end ('2022-09-01'::timestamp), 
    partition p20220901 start('2022-09-01'::timestamp) end ('2022-09-02'::timestamp), 
    partition p20220902 start('2022-09-02'::timestamp) end ('2022-09-03'::timestamp), 
    partition p20220903 start('2022-09-03'::timestamp) end ('2022-09-04'::timestamp), 
    partition p20220904 start('2022-09-04'::timestamp) end ('2022-09-05'::timestamp), 
    partition p20220905 start('2022-09-05'::timestamp) end ('2022-09-06'::timestamp),
    DEFAULT PARTITION pother  
)
;
CREATE INDEX idx_weblog_data ON weblog.weblog_data USING btree (userid);

-- Weblog를 사용자별 변환 적재 테이블  
-- DROP TABLE weblog.weblog_sum_user_dd;
CREATE TABLE weblog.weblog_sum_user_dd (
	log_dt text NULL,
	userid varchar NULL,
	log_tm_arr _timestamp NULL,
	eid_arr _int4 NULL,
	dt_arr _int4 null,
	last_update timestamp
)
with (appendonly=true, compresslevel=1, compresstype=zstd)
DISTRIBUTED BY (userid)
partition by range(log_dt)
(
    partition p20220831 start('20220831') end ('20220901'), 
    partition p20220901 start('20220901') end ('20220902'), 
    partition p20220902 start('20220902') end ('20220903'), 
    partition p20220903 start('20220903') end ('20220904'), 
    partition p20220904 start('20220904') end ('20220905'), 
    partition p20220905 start('20220905') end ('20220906'),
    DEFAULT PARTITION pother  
)
CREATE INDEX idx_weblog_sum_user_dd ON weblog.weblog_sum_user_dd USING btree (userid);


--웹로그를 생성을 위한 함수, 유저별 새로운 페이지 로깅, 시간과 페이지 생성 함수    
create or replace function weblog.udf_gen_weblog_data_user
(
    v_uqid     INOUT VARCHAR,
    v_userid   INOUT VARCHAR,
    v_eid      INOUT int,
    v_log_tm   INOUT timestamp,
    v_peid     INOUT int,
    v_dt       INOUT int,
    v_ip       INOUT VARCHAR
) 
as
$$
declare 
            v_log_tm_new timestamp;
            v_eid_tmp    int;
begin

	        v_log_tm_new     := v_log_tm + (trim(to_char(v_dt, '99'))||' second')::interval;

            v_uqid    :=  v_uqid;
            v_userid  :=  v_userid;
            v_peid    :=  v_eid;
            v_eid_tmp := trunc(mod((random() * 1000000)::int, 1000) + 1);
            
            if     v_eid_tmp > 0 and  v_eid_tmp < 10 then v_eid := 1;
            elsif  v_eid_tmp < 60   then v_eid := 2;
            elsif  v_eid_tmp < 78   then v_eid := 3;
            elsif  v_eid_tmp < 138  then v_eid := 4;
            elsif  v_eid_tmp < 143  then v_eid := 5;
            elsif  v_eid_tmp < 228  then v_eid := 6;
            elsif  v_eid_tmp < 260  then v_eid := 7;
            elsif  v_eid_tmp < 315  then v_eid := 8;
            elsif  v_eid_tmp < 345  then v_eid := 9;
            elsif  v_eid_tmp < 375  then v_eid := 10;
            elsif  v_eid_tmp < 455  then v_eid := 11;
            elsif  v_eid_tmp < 465  then v_eid := 12;
            elsif  v_eid_tmp < 515  then v_eid := 13;
            elsif  v_eid_tmp < 520  then v_eid := 14;
            elsif  v_eid_tmp < 535  then v_eid := 15;
            elsif  v_eid_tmp < 555  then v_eid := 16;
            elsif  v_eid_tmp < 580  then v_eid := 17;
            elsif  v_eid_tmp < 590  then v_eid := 18;
            elsif  v_eid_tmp < 605  then v_eid := 19;
            elsif  v_eid_tmp < 622  then v_eid := 20;
            elsif  v_eid_tmp < 640  then v_eid := 21;
            elsif  v_eid_tmp < 640  then v_eid := 22;
            elsif  v_eid_tmp < 670  then v_eid := 23;
            elsif  v_eid_tmp < 694  then v_eid := 24;
            elsif  v_eid_tmp < 705  then v_eid := 25;
            elsif  v_eid_tmp < 717  then v_eid := 26;
            elsif  v_eid_tmp < 727  then v_eid := 27;
            elsif  v_eid_tmp < 737  then v_eid := 28;
            elsif  v_eid_tmp < 749  then v_eid := 29;
            elsif  v_eid_tmp < 764  then v_eid := 30;
            elsif  v_eid_tmp < 794  then v_eid := 31;
            elsif  v_eid_tmp < 806  then v_eid := 32;
            elsif  v_eid_tmp < 814  then v_eid := 33;
            elsif  v_eid_tmp < 829  then v_eid := 34;
            elsif  v_eid_tmp < 846  then v_eid := 35;
            elsif  v_eid_tmp < 865  then v_eid := 36;
            elsif  v_eid_tmp < 940  then v_eid := 37;
            elsif  v_eid_tmp < 1000 then v_eid := 38;

            end if;            
            v_dt      :=  (60 * random())::int;
            v_log_tm  :=  v_log_tm_new;
            v_ip      :=  v_ip;
end;
$$
language plpgsql;

--웹로그를 생성을 위한 함수, 특정날짜 기준으로 유저별 단일 row 생성 함수 
create or replace function weblog.udf_gen_weblog_data(
    v_work_dt  IN  VARCHAR,
    v_uqid     OUT VARCHAR,
    v_userid   OUT VARCHAR,
    v_eid      OUT int,
    v_log_tm   OUT timestamp,
    v_peid     OUT int,
    v_dt       OUT int,
    v_ip       OUT VARCHAR
)
AS
$$
declare 
            v_work_date timestamp;
            v_rnd_val  numeric;
            v_ip_1  int;
            v_ip_2  int;
            v_ip_3  int;
            v_ip_4  int;
            v_log_hh24 int;
            ----등록된 코드 건수
            v_eid_cnt int default 38;
            
     BEGIN
            v_work_date := v_work_dt::timestamp;
            v_rnd_val := random();

            v_userid  :=  trim(to_char(trunc(mod((random() * 100000000)::int, 20000000) + 1), '000000000'));           
            v_uqid    :=  substr(md5(v_userid), 1, 24); 
            v_eid     :=  trunc(mod((random() * 100)::int, v_eid_cnt) + 1);
            
            v_log_hh24  :=  trunc(mod((random() * 100000000)::int, 1000));
            
            if    v_log_hh24 < 50   then v_log_tm := v_work_date +  '0 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval;           
            elsif v_log_hh24 < 80   then v_log_tm := v_work_date +  '1 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 95   then v_log_tm := v_work_date +  '2 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 105  then v_log_tm := v_work_date +  '3 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 115  then v_log_tm := v_work_date +  '4 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 123  then v_log_tm := v_work_date +  '5 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 128  then v_log_tm := v_work_date +  '6 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 137  then v_log_tm := v_work_date +  '7 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 152  then v_log_tm := v_work_date +  '8 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 182  then v_log_tm := v_work_date +  '9 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 222  then v_log_tm := v_work_date +  '10 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 272  then v_log_tm := v_work_date +  '11 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 317  then v_log_tm := v_work_date +  '12 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 367  then v_log_tm := v_work_date +  '13 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 422  then v_log_tm := v_work_date +  '14 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 482  then v_log_tm := v_work_date +  '15 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 547  then v_log_tm := v_work_date +  '16 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 617  then v_log_tm := v_work_date +  '17 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 709  then v_log_tm := v_work_date +  '18 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 771  then v_log_tm := v_work_date +  '19 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 846  then v_log_tm := v_work_date +  '20 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 896  then v_log_tm := v_work_date +  '21 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 941  then v_log_tm := v_work_date +  '22 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            elsif v_log_hh24 < 1000 then v_log_tm := v_work_date +  '23 hour'::interval + (trim(to_char(trunc((3600 * random())), '9999'))||' second')::interval; 
            end if;                                     
                  
            v_dt      :=  trunc(mod((random() * 100)::int, 60) + 1);
            v_ip_1    :=  trunc(mod((random() * 300)::int, 255) + 1);
            v_ip_2    :=  trunc(mod((random() * 300)::int, 255) + 1);
            v_ip_3    :=  trunc(mod((random() * 300)::int, 255) + 1);
            v_ip_4    :=  trunc(mod((random() * 300)::int, 255) + 1);
            
            v_ip      := TRIM(to_char(v_ip_1, '999'))||'.'||TRIM(to_char(v_ip_2, '999'))||'.'||TRIM(to_char(v_ip_3, '999'))||'.'||TRIM(to_char(v_ip_4, '999'));

end;
$$
language plpgsql;

--웹로그 생성, 날짜와 세션 개수를 인자로, 특정 날짜의 데이터를 생성 후 weblog.weblog_data_base 테이에 적재하는 프로시져  
create or replace function weblog.sp_gen_weblog_data_base(
   v_work_dt     VARCHAR ,
   v_session_cnt int
)
returns int
AS
$$
declare 

      v_uqid     VARCHAR;
      v_userid   VARCHAR;
      v_eid      int;
      v_log_tm   timestamp;
      v_peid     int;
      v_dt       int;
      v_ip       VARCHAR;
      
      v_pv_cnt int;
      v_max_pv int default 100;
     
      v_row_cnt  int default 0;
     
BEGIN
/*         
         DELETE from weblog.weblog_data
         WHERE  log_tm >= v_work_dt::timestamp
         AND    log_tm <  v_work_dt::timestamp + '1 day'::interval;
*/         
         
         for i in 1..v_session_cnt
         LOOP
             select  * from weblog.udf_gen_weblog_data(v_work_dt)
                  into   v_uqid,
                         v_userid,
                         v_eid,
                         v_log_tm,
                         v_peid,
                         v_dt,
                         v_ip;
                  
	         
             --Max 
             v_pv_cnt := MOD((random() * 100000000)::int, v_max_pv);

             FOR i IN 1..v_pv_cnt
             LOOP

              select * from weblog.udf_gen_weblog_data_user(
                                             v_uqid,
                                             v_userid,
                                             v_eid,
                                             v_log_tm,
                                             v_peid,
                                             v_dt,
                                             v_ip)
                 into v_uqid, v_userid, v_eid, v_log_tm, v_peid, v_dt, v_ip; 
                 -- userid가 null 생성                         
--                 IF MOD((random() * 100000000)::int, 100)  = 0  THEN 
--                    v_userid := NULL;
--                 END IF;
                 
                 -- 초기 접근시, 이전 메뉴(이전 페이지) -1 
                 IF i = 1 THEN 
                    v_peid := -1;
                 END IF;
                 
                 INSERT into weblog.weblog_data_base
                   (uqid, userid, eid, log_tm, peid, dt, ip)
                 VALUES
                   --(v_uqid, case when i = 1 then null else v_userid end, v_eid, v_log_tm, v_peid, v_dt, v_ip);
                 (v_uqid,  v_userid, v_eid, v_log_tm, v_peid, v_dt, v_ip);
                  
                 v_row_cnt := v_row_cnt+1; 
                   
             END LOOP;             
         end loop;        
         return v_row_cnt;
        
 end;
$$
language plpgsql;


--weblog.weblog_data_base 에 생성된 데이터를 weblog.weblog_data 증분하여 적재 
--증분 시작번호, 증분 종료번호, 증분시 offset (사용ID, 체류시간 적)
create or replace function weblog.sp_multiple_weblog_data(v_start int, v_stop int, v_offset int)
returns int
AS
$$
declare 
     
BEGIN
                
         for v_i in v_start..v_stop
         LOOP
				insert into weblog.weblog_data
				(uqid, userid, eid, log_tm, peid, dt, ip)
				SELECT  substr(md5(trim(to_char((userid::int)+(v_i*v_offset), '000000000'))), 1, 24)
					  , trim(to_char((userid::int)+(v_i*v_offset), '000000000')) userid
					  , eid
					  , log_tm + (trim(to_char(v_i*v_offset, '999999'))||' sec')::interval
					  , peid
					  , dt
					  , ip
				FROM weblog.weblog_data_base
				;
             
         end loop;
         return v_stop -v_start ;
        
 end;
$$
language plpgsql;

