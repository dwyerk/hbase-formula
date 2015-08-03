# hbase-formula

Formula to set up and configure hbase components

Note: See the full [Salt Formulas installation and usage instructions](http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).

## Available States

1. hbase

## hbase

Downloads the hbase tarball from the hbase:source_url, installs the package and
the hbase service.

Which services hbase ends up running on a given host depends on the roles
defined via salt grains:

- hadoop_master will run the hbase-master and hbase-stargate services
- hadoop_slave will run the hbase-regionserver service

## Formula Dependencies

1. hadoop

Note: the version of hbase that this formula currently installs requires a new
enough version of hadoop. I have successfully tested with the following in my
hadoop pillar:

```
hadoop:
  version: apache-2.5.2
```

