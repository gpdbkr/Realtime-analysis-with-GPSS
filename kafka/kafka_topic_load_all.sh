cd /data1/kafka/kafka_data/

CNT=0

START_TM1=`date "+%Y-%m-%d %H:%M:%S"`
SHMS=`echo $START_TM1 | awk '{print $2}'`
SEC1=`date +%s -d ${SHMS}`

for i  in `ls log_*`
do
CNT=$(expr $CNT + 1)

echo "################### Beginning: load to kafka"
echo "################### File Count:" $CNT
echo "################### loading file name:" $i
/usr/local/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic weblog.stag_weblog_data < /data1/kafka/kafka_data/$i


END_TM1=`date "+%Y-%m-%d %H:%M:%S"`
EHMS=`echo $END_TM1   | awk '{print $2}'`
SEC2=`date +%s -d ${EHMS}`
DIFFSEC=`expr ${SEC2} - ${SEC1}`

TPS=`expr 50000 \* ${CNT} / ${DIFFSEC}`
echo 
echo "################### End: load to kafka"
echo "################### Elapsed seconds:" $DIFFSEC
echo "################### TPS :" $TPS
echo 
echo 
done
