--웹로그의 URL이 eid로 맵핑되고, 해당 url의 사용자 카테고리로 정의 
--샘플데이터 적재 
truncate table weblog.weblog_menu;
insert into weblog.weblog_menu values (1,'검색',null,null);
insert into weblog.weblog_menu values (2,'검색','디렉토리',null);
insert into weblog.weblog_menu values (3,'검색','동영상',null);
insert into weblog.weblog_menu values (4,'검색','가격비교',null);
insert into weblog.weblog_menu values (5,'뉴스',null,null);
insert into weblog.weblog_menu values (6,'뉴스','종합',null);
insert into weblog.weblog_menu values (7,'뉴스','연예',null);
insert into weblog.weblog_menu values (8,'뉴스','스포츠',null);
insert into weblog.weblog_menu values (9,'뉴스','핫이슈',null);
insert into weblog.weblog_menu values (10,'뉴스','날씨',null);
insert into weblog.weblog_menu values (11,'커뮤니티','블로그',null);
insert into weblog.weblog_menu values (12,'커뮤니티','클럽',null);
insert into weblog.weblog_menu values (13,'커뮤니티','클럽','클럽 랭킹');
insert into weblog.weblog_menu values (14,'쇼핑',null,null);
insert into weblog.weblog_menu values (15,'쇼핑','공동구매',null);
insert into weblog.weblog_menu values (16,'쇼핑','의류',null);
insert into weblog.weblog_menu values (17,'쇼핑','의류','여성');
insert into weblog.weblog_menu values (18,'쇼핑','의류','남성');
insert into weblog.weblog_menu values (19,'쇼핑','전자제품',null);
insert into weblog.weblog_menu values (20,'쇼핑','전자제품','디카');
insert into weblog.weblog_menu values (21,'쇼핑','전자제품','TV');
insert into weblog.weblog_menu values (22,'오락',null,null);
insert into weblog.weblog_menu values (23,'오락','영화',null);
insert into weblog.weblog_menu values (24,'오락','영화','추천영화');
insert into weblog.weblog_menu values (25,'오락','영화','영화전체');
insert into weblog.weblog_menu values (26,'오락','만화',null);
insert into weblog.weblog_menu values (27,'오락','만화','순정만화');
insert into weblog.weblog_menu values (28,'오락','만화','스포츠 만화');
insert into weblog.weblog_menu values (29,'금융',null,null);
insert into weblog.weblog_menu values (30,'금융','재태크',null);
insert into weblog.weblog_menu values (31,'금융','재태크','보험');
insert into weblog.weblog_menu values (32,'금융','재태크','증권');
insert into weblog.weblog_menu values (33,'금융','부동산',null);
insert into weblog.weblog_menu values (34,'금융','부동산','매매');
insert into weblog.weblog_menu values (35,'금융','부동산','경매');
insert into weblog.weblog_menu values (36,'금융','부동산','전세');
insert into weblog.weblog_menu values (37,'메인','로그인전',null);
insert into weblog.weblog_menu values (38,'메인','로그인후',null);

--특정 날짜에 n개 세션을 생성 
--user, ip, 이전 페이지, 이후 페이지 등을 row 단위로 생성하기 때문에 다소 느림. 
--Generate 1000 visits data for 2022-08-13

truncate table weblog.weblog_data_base;
select     weblog.sp_gen_weblog_data_base('2022-08-31', 1000);
select     weblog.sp_gen_weblog_data_base('2022-08-31', 1000);
select     weblog.sp_gen_weblog_data_base('2022-08-31', 1000);
select     weblog.sp_gen_weblog_data_base('2022-08-31', 1000);
select     weblog.sp_gen_weblog_data_base('2022-08-31', 1000);

analyze weblog.weblog_data_base;

--weblog.weblog_data_base의 테이블을 이용하여 weblog.weblog_data에 데이터 증분 적재
--userid와 접속시간(초)을 13을 증분하면서 400번 증식
truncate table weblog.weblog_data;   
select weblog.sp_multiple_weblog_data(0, 400, 13);

analyze weblog.weblog_data;
analyze weblog.weblog_menu;

--사용자가 접속한 웹페이지 히스토리 
SELECT userid, log_tm, b.d1, b.d2, b.d3, dt 
FROM  weblog.weblog_data a 
    , weblog.weblog_menu b
where a.eid = b.eid 
and   userid = '002646584'  --Ramdon으로 데이터 를 생성하기 때문에, 특정 ID를 추출 후 조건에 입력 
order by log_tm
;

--웹로그 집계 - Depth 1 
SELECT  to_char(log_tm, 'yyyymmdd') log_dt
--       , to_char(log_tm, 'hh24') log_hr
       , b.d1 
       , COUNT(*) pv
       , COUNT(DISTINCT userid) lv 
       , COUNT(DISTINCT ip) ips 
       , SUM(dt) dt
FROM   weblog.weblog_data a
       , weblog.weblog_menu b
WHERE  a.eid = b.eid
GROUP BY to_char(log_tm, 'yyyymmdd') 
--       , to_char(log_tm, 'hh24') 
         , b.d1 
order by 1, 2 
;

--웹로그 집계 - Depth 2 
SELECT  to_char(log_tm, 'yyyymmdd') log_dt
--       , to_char(log_tm, 'hh24') log_hr
       , b.d1, b.d2 
       , COUNT(*) pv
       , COUNT(DISTINCT userid) lv 
       , COUNT(DISTINCT ip) ips 
       , SUM(dt) dt
FROM   weblog.weblog_data a
       , weblog.weblog_menu b
WHERE  a.eid = b.eid
GROUP BY to_char(log_tm, 'yyyymmdd') 
--       , to_char(log_tm, 'hh24') 
         , b.d1, b.d2
order by 1, 2, 3 
;

--웹로그 집계 - Depth 3
SELECT  to_char(log_tm, 'yyyymmdd') log_dt
--       , to_char(log_tm, 'hh24') log_hr
       , b.d1, b.d2, b.d3 
       , COUNT(*) pv
       , COUNT(DISTINCT userid) lv 
       , COUNT(DISTINCT ip) ips 
       , SUM(dt) dt
FROM   weblog.weblog_data a
       , weblog.weblog_menu b
WHERE  a.eid = b.eid
GROUP BY to_char(log_tm, 'yyyymmdd') 
--       , to_char(log_tm, 'hh24') 
         , b.d1, b.d2, b.d3
order by 1, 2, 3 
;
