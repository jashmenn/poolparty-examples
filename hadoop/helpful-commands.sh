http://www.michael-noll.com/wiki/Running_Hadoop_On_Ubuntu_Linux_(Single-Node_Cluster)

sudo -u hadoop -H /usr/local/hadoop/bin/hadoop dfs -rmr gutenberg-output
sudo -u hadoop -H /usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/hadoop-0.20.0-examples.jar wordcount gutenberg gutenberg-output
sudo -u hadoop -H ./bin/hadoop dfs -copyFromLocal /tmp/gutenberg gutenberg
sudo -u hadoop -H ./bin/stop-all.sh 
sudo -u hadoop -H ./bin/start-dfs.sh
sudo -u hadoop -H ./bin/start-mapred.sh
ec2-run-instances -k nmurray-hadoop-slave ami-bf5eb9d6
http://ip:50075/browseDirectory.jsp?namenodeInfoPort=50070&dir=%2F
grep -R port *|  grep -vi import | grep -vi report | grep -vi support
/usr/local/hadoop/bin/hadoop namenode -format

/usr/local/hadoop/bin/start-dfs.sh
/usr/local/hadoop/bin/start-mapred.sh
/usr/local/hadoop/bin/hadoop dfs -rmr gutenberg-output
/usr/local/hadoop/bin/hadoop dfs -copyFromLocal /tmp/gutenberg gutenberg
/usr/local/hadoop/bin/hadoop dfs -ls
/usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/hadoop-0.20.0-examples.jar wordcount gutenberg gutenberg-output
/usr/local/hadoop/bin/stop-all.sh 
/usr/local/hadoop/bin/hadoop dfs -copyToLocal gutenberg-output /tmp/gutenberg-output

http://ec2-174-129-134-128.compute-1.amazonaws.com:50030/mapOutput?job=job_200906172320_0001&map=attempt_200906172320_0001_m_000000_0&reduce=0
xtail --ansi logs/*.log
scp -o "IdentityFile ~/.ssh/nmurray-hadoop-master"  root@xx.xx.xx.xx:/usr/local/hadoop/conf.tar.bz2 .
scp -r -o "IdentityFile ~/.ssh/cloudteam_hadoop_master" root@xxx.xxx.xxx.xx:/usr/local/src/jruby-jdbc jruby-jdbc

# hive
HIVE_PORT=10000 hive --service hiveserver
