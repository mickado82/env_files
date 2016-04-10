#
# Dockerfile user to launch a Spark client that can connect to Mesos to be launched on a cluster
#
# To build the image : 
# sudo docker build -t spark-with-mesos_image
#
# to run the container:
#
# sudo docker run -ti --net=host -v /REPLACE_ME_HOST_DIR:/home/hduser/shared --name spark-with-mesos spark-with-mesos_image /bin/bash
#
# to start it:
#
# sudo docker start spark-with-mesos then attach with sudo docker attach spark-with-mesos
#
# Inside the container you can run a spark shell with:
#
# sudo -E /spark/bin/spark-shell --master mesos://zk://REPLACE_ME_ZK_HOST/mesos --verbose --num-executors 20 --executor-memory 15G
#
#


FROM ubuntu:14.04
MAINTAINER Mickael Morin (morin.mickaemickael.fr@gmail.com)

# Proxy setting
ENV http_proxy http://REPLACE_ME_PROXY_HOST:REPLACE_ME_PROXY_PORT/
ENV https_proxy http://REPLACE_ME_PROXY_HOST:REPLACE_ME_PROXY_PORT/

#Mesosphere repo
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]'); CODENAME=$(lsb_release -cs); echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | tee /etc/apt/sources.list.d/mesosphere.list
RUN cat /etc/apt/sources.list.d/mesosphere.list

# System upgrade
RUN apt-get update
#RUN apt-get upgrade -y

# Tools installation
RUN apt-get install -y vim htop

# Java installation
RUN apt-get install -y openjdk-7-jre openjdk-7-jdk
ENV JAVA_HOME /usr/lib/jvm/jdk
RUN ln -s /usr/lib/jvm/java-7-openjdk-amd64 $JAVA_HOME

# SSH installation
RUN apt-get install -y ssh rsync
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN sed -i '/Port 22/c\Port 40022' /etc/ssh/sshd_config

# Hadoop installation
ADD http://REPLACE_ME_HADOOP_LOCATION/hadoop-2.4.1.tar.gz /
RUN tar -xzf hadoop-2.4.1.tar.gz
RUN mv /hadoop-2.4.1 /hadoop
RUN rm -rf hadoop-2.4.1.tar.gz
ADD core-site.xml /hadoop/etc/hadoop/core-site.xml
ADD hdfs-site.xml /hadoop/etc/hadoop/hdfs-site.xml
ADD yarn-site.xml /hadoop/etc/hadoop/yarn-site.xml
ADD mapred-site.xml /hadoop/etc/hadoop/mapred-site.xml
RUN sed -i '/export JAVA_HOME=${JAVA_HOME}/c\export JAVA_HOME=/usr/lib/jvm/jdk' /hadoop/etc/hadoop/hadoop-env.sh

# Spark installation
ADD http://REPLACE_ME_SPARK_LOCATION/spark-1.5.2-bin-hadoop2.4.tgz /
RUN tar -xzf spark-1.5.2-bin-hadoop2.4.tgz
RUN mv /spark-1.5.2-bin-hadoop2.4 /spark
RUN rm -rf spark-1.5.2-bin-hadoop2.4.tgz

#Mesos Installation
RUN apt-get -y install mesos=0.22.1-1.0.ubuntu1404

# Hadoop user creation
RUN addgroup hadoop
RUN useradd -d /home/hduser -m -s /bin/bash -G hadoop hduser
RUN sudo adduser hduser sudo
RUN echo 'hduser:hduser' | chpasswd

# SSH config
RUN su hduser -c "ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ''"
RUN su hduser -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
ADD ssh_config ./ssh_config
RUN mv ./ssh_config /home/hduser/.ssh/config

# Launch scripts
ENV PATH=$PATH:/hadoop/bin:/spark/bin:$JAVA_HOME
#Seems Hive context can not be init when this env var is uncommented
ENV HADOOP_CLASSPATH=${JAVA_HOME}/lib/tools.jar
#ENV HADOOP_CONF_DIR=/hadoop/etc/hadoop
ADD starthadoop.sh /home/hduser/starthadoop.sh
RUN chmod 700 /home/hduser/starthadoop.sh

# Code examples
ADD examples /home/hduser/examples

# Permissions
RUN chown -R hduser:hduser /home/hduser
RUN chmod 700 /home/hduser/.ssh ; chmod 600 /home/hduser/.ssh/authorized_keys ; chmod go-wrx /home/hduser
RUN chown -R hduser:hduser /hadoop
ADD hduser-sudoer /etc/sudoers.d/hduser-sudoer

#ENV vars 

ENV MESOS_NATIVE_JAVA_LIBRARY /usr/local/lib/libmesos.so
ENV SPARK_EXECUTOR_URI http://sep467ubuntu:8000/spark-1.5.2-bin-hadoop2.4.tgz

# Select workdir and user
WORKDIR /home/hduser
USER hduser
