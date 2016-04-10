# Start sshd
sudo service ssh start

# Initialize Hadoop
hdfs namenode -format
/hadoop/sbin/start-dfs.sh
hdfs dfs -mkdir /user
hdfs dfs -mkdir /user/hduser

# Initialiaz Spark
/spark/sbin/start-master.sh
