henk52-logstash
===============

# Installation
See: https://www.elastic.co/guide/en/elasticsearch/reference/5.1/zip-targz.html

1. puppet apply install.pp
2. chown -R elk /opt/elasticsearch/

Kibana:

* /opt/kibana/config/kibana.yml
* server.host: "0.0.0.0"

Get status of Kibana:
1. localhost:5601/status

Puppet module for installing logstash
o
* curl http://localhost:9200/_nodes?pretty



* wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.3.3/elasticsearch-2.3.3.tar.gz
* wget https://download.elastic.co/logstash/logstash/logstash-all-plugins-2.3.1.tar.gz
* wget https://download.elastic.co/kibana/kibana/kibana-4.5.1-linux-x86.tar.gz



