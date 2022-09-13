/usr/local/kafka/bin/kafka-topics.sh --zookeeper localhost:2181/greenplum-kafka --topic weblog.weblog_data --delete
/usr/local/kafka/bin/kafka-topics.sh --zookeeper localhost:2181/greenplum-kafka --topic weblog.stag_weblog_data --delete
