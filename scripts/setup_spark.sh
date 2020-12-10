#!/bin/bash -x

# TensorFlow 2.0.0 is tested/supported on Ubuntu 16 (xenial) or later
# But Travis' xenial build env uses JDK11, while Spark requires JDK8

# Install JDK8
add-apt-repository -y ppa:openjdk-r/ppa
apt-get update
apt-get install -y openjdk-8-jdk --no-install-recommends
update-java-alternatives -s java-1.8.0-openjdk-amd64
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Install Spark
export SPARK_VERSION=2.4.7
curl -LO http://www-us.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz
export SPARK_HOME=./spark
mkdir $SPARK_HOME
tar -xf spark-${SPARK_VERSION}-bin-hadoop2.7.tgz -C $SPARK_HOME --strip-components=1
export SPARK_LOCAL_IP=127.0.0.1
export PATH=$SPARK_HOME/bin:$PATH

# Start Spark Standalone Cluster
export SPARK_CLASSPATH=./lib/tensorflow-hadoop-1.0-SNAPSHOT.jar
export MASTER=spark://$(hostname):7077
export SPARK_WORKER_INSTANCES=2; export CORES_PER_WORKER=1
export TOTAL_CORES=$((${CORES_PER_WORKER}*${SPARK_WORKER_INSTANCES}))
${SPARK_HOME}/sbin/start-master.sh; ${SPARK_HOME}/sbin/start-slave.sh -c ${CORES_PER_WORKER} -m 1G ${MASTER}
