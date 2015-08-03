{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hbase/settings.sls' import hbase with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
{%- from 'zookeeper/settings.sls' import zk with context %}

# TODO: no users implemented in settings yet
{%- set hadoop_users = hadoop.get('users', {}) %}
{%- set uid = hadoop_users.get(hbase.username, '6004') %}

{{ hadoop_user(hbase.username, uid) }}

unpack-hbase-dist:
  cmd.run:
    - name: curl -L '{{ hbase.source_url }}' | tar xz --no-same-owner
    - cwd: /usr/lib
    - unless: test -d {{ hbase.real_home }}

/usr/lib/hbase:
  file.symlink:
    - target: {{ hbase.real_home }}

{{ hbase.logdir }}:
  file.directory:
    - user: hbase
    - group: hbase
    - makedirs: True

{{ hbase.real_home }}/conf/hbase-site.xml:
  file.managed:
    - source: salt://hbase/conf/hbase-site.xml
    - template: jinja
    - mode: 644
    - context:
      zookeeper_quorum: {{ zk.connection_string }}

{{ hbase.real_home }}/conf/log4j.properties:
  file.managed:
    - source: salt://hbase/conf/log4j.properties
    - template: jinja
    - mode: 644

{{ hbase.real_home }}/conf/hbase-env.sh:
  file.managed:
    - source: salt://hbase/conf/hbase-env.sh
    - template: jinja
    - mode: 644

{{ hbase.real_home }}/conf/regionservers:
  file.managed:
    - mode: 644
    - contents: |
{%- for slave in hbase.regionserver_hosts %}
        {{ slave }}
{%- endfor %}


{% if hbase.is_master %}

create-hbase-storage:
  cmd.run:
    - name: {{ hadoop.alt_home }}/bin/hadoop fs -mkdir /hbase; {{ hadoop.alt_home }}/bin/hadoop fs -chown {{ hbase.username }} /hbase
    - unless: {{ hadoop.alt_home }}/bin/hadoop fs -ls /hbase
    - user: hdfs

/etc/init.d/hbase-master:
  file.managed:
    - source: salt://hbase/files/{{ hbase.initscript }}
    - user: root
    - group: root
    - mode: '755'
    - template: jinja
    - context:
      hadoop_svc: master
      hadoop_user: hbase
      hadoop_major: {{ hadoop.major_version }}
      hadoop_home: {{ hadoop.alt_home }}

/etc/init.d/hbase-stargate:
  file.managed:
    - source: salt://hbase/files/{{ hbase.sg_initscript }}
    - user: root
    - group: root
    - mode: '755'
    - template: jinja
    - context:
      hadoop_svc: master
      hadoop_user: hbase
      hadoop_major: {{ hadoop.major_version }}
      hadoop_home: {{ hadoop.alt_home }}

{% endif %}

{% if hbase.is_regionserver %}
/etc/init.d/hbase-regionserver:
  file.managed:
    - source: salt://hbase/files/{{ hbase.rs_initscript }}
    - user: root
    - group: root
    - mode: '755'
    - template: jinja
    - context:
      hadoop_svc: regionserver
      hadoop_user: hbase
      hadoop_major: {{ hadoop.major_version }}
      hadoop_home: {{ hadoop.alt_home }}
{% endif %}

hbase-services:
  service.running:
    - enable: True
    - names:
{% if hbase.is_master %}
      - hbase-master
      - hbase-stargate
{% endif %}
{% if hbase.is_regionserver %}
      - hbase-regionserver
{% endif %}
