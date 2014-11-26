#!/usr/bin/bash

echo "III starting elasticsearch."
sudo /opt/elasticsearch/bin/elasticsearch -d -p /var/run/elasticsearch.pid
echo "III starting kibana(logstash-web)"
sudo /opt/logstash/bin/logstash-web
