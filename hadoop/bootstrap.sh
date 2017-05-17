#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
# spark path
export SPARK_DIST_CLASSPATH=`$HADOOP_PREFIX/bin/hadoop classpath`
export SPARK_HOME=/usr/local/spark
export SPARK_CONF_DIR=$SPARK_HOME/conf
# zeppelin path
export ZEPPELIN_HOME=/usr/local/zeppelin
export ZEPPELIN_NOTEBOOK_DIR=/data/zeppelin/notebook
# create Zeppelin notebook dir

if [ ! -d $ZEPPELIN_NOTEBOOK_DIR ]; then
    echo "create zeppelin notebook dir : $ZEPPELIN_NOTEBOOK_DIR"
    mkdir -p $ZEPPELIN_NOTEBOOK_DIR
    cp -rp /usr/local/zeppelin/notebook/* $ZEPPELIN_NOTEBOOK_DIR
fi

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml

service sshd start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh
$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh start historyserver
$ZEPPELIN_HOME/bin/zeppelin-daemon.sh restart

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
