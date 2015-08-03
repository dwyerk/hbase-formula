{%- set p  = salt['pillar.get']('hbase', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('hbase', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set master_target     = g.get('master_target', p.get('master_target', 'roles:hadoop_master')) %}
{%- set regionserver_target     = g.get('regionserver_target', p.get('regionserver_target', 'roles:hadoop_slave')) %}
# this is a deliberate duplication as to not re-import hadoop/settings multiple times
{%- set targeting_method    = salt['grains.get']('hadoop:targeting_method', salt['pillar.get']('hadoop:targeting_method', 'grain')) %}
{%- set namenode_host       = salt['mine.get'](master_target, 'network.interfaces', expr_form=targeting_method)|first %}
{%- set regionservers      = salt['mine.get'](regionserver_target, 'network.interfaces', expr_form=targeting_method).keys() %}
{%- set namenode_port       = gc.get('namenode_port', pc.get('namenode_port', '8020')) %}

{%- set is_master = salt['match.' ~ targeting_method](master_target) %}
{%- set is_regionserver = salt['match.' ~ targeting_method](regionserver_target) %}

{%- set source_url = 'http://apache.osuosl.org/hbase/1.0.1.1/hbase-1.0.1.1-bin.tar.gz' %}
{%- set real_home = '/usr/lib/hbase-1.0.1.1' %}
{%- set rootdir = 'hdfs://' ~ namenode_host ~ ':' ~ namenode_port ~ '/hbase' %}
{%- set initscript = 'hbase.init' %}
{%- set rs_initscript = 'hbase-regionserver.init' %}
{%- set sg_initscript = 'hbase-stargate.init' %}
{%- set logdir = '/var/log/hbase' %}
{%- set username = 'hbase' %}

{%- set hbase = {} %}
{%- do hbase.update({
    'master_host' : namenode_host,
    'regionserver_hosts': regionservers,
    'is_master': is_master,
    'is_regionserver': is_regionserver,
    'tmp_dir': tmp_dir,
    'source_url': source_url,
    'real_home': real_home,
    'rootdir': rootdir,
    'initscript': initscript,
    'rs_initscript': rs_initscript,
    'sg_initscript': sg_initscript,
    'logdir': logdir,
    'username': username
}) %}
