sudo -u hadoop -H /usr/local/hadoop/bin/hadoop dfs -rmr gutenberg-output
sudo -u hadoop -H /usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/hadoop-0.20.0-examples.jar wordcount gutenberg gutenberg-output
sudo -u hadoop -H ./bin/hadoop dfs -copyFromLocal /tmp/gutenberg gutenberg
sudo -u hadoop -H ./bin/stop-all.sh 
sudo -u hadoop -H ./bin/start-dfs.sh
sudo -u hadoop -H ./bin/start-mapred.sh
ec2-run-instances -k nmurray-hadoop-slave ami-bf5eb9d6
http://ip:50075/browseDirectory.jsp?namenodeInfoPort=50070&dir=%2F
grep -R port *|  grep -vi import | grep -vi report | grep -vi support

/usr/local/hadoop/bin/hadoop dfs -rmr gutenberg-output
/usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/hadoop-0.20.0-examples.jar wordcount gutenberg gutenberg-output
/usr/local/hadoop/bin/hadoop dfs -copyFromLocal /tmp/gutenberg gutenberg
/usr/local/hadoop/bin/stop-all.sh 
/usr/local/hadoop/bin/start-dfs.sh
/usr/local/hadoop/bin/start-mapred.sh
/usr/local/hadoop/bin/hadoop dfs -ls
/usr/local/hadoop/bin/hadoop namenode -format


http://ec2-174-129-134-128.compute-1.amazonaws.com:50030/mapOutput?job=job_200906172320_0001&map=attempt_200906172320_0001_m_000000_0&reduce=0
