{%- from 'hbase/settings.sls' import hbase with context %}
export HBASE_OPTS="-XX:+UseConcMarkSweepGC"
export HBASE_LOG_DIR="{{ hbase.logdir }}"
