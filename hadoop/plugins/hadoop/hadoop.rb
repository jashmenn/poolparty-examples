=begin rdoc
=end

module PoolParty
  module Plugin
    class Hadoop < Plugin
      def before_load(o={}, &block)
        install_jdk
        add_users_and_groups
        build
        configure
        format_hdfs
      end

      def install_jdk
        # accept the sun license agreements. see: http://www.davidpashley.com/blog/debian/java-license
        has_exec "echo sun-java6-jdk shared/accepted-sun-dlj-v1-1 select true | /usr/bin/debconf-set-selections"
        has_exec "echo sun-java6-jre shared/accepted-sun-dlj-v1-1 select true | /usr/bin/debconf-set-selections"
        has_package(:name => "sun-java6-jdk")
        has_file(:name => "/etc/jvm") do
            mode 0644
            template :plugins/:hadoop/:templates/"jvm.conf"
         end
      end

      def add_users_and_groups
        has_group "hadoop", :action => :create
        has_user "hadoop", :gid => "hadoop"
        has_directory "/home/hadoop", :owner => "hadoop", :mode => "755"
        has_exec "ssh-keygen -t rsa -N '' -f /home/hadoop/.ssh/id_rsa", :user => "hadoop", 
          :not_if => "test -e /home/hadoop/.ssh/id_rsa"
        has_exec "cp /home/hadoop/.ssh/id_rsa.pub /home/hadoop/.ssh/authorized_keys",
          :not_if => "test -e /home/hadoop/.ssh/authorized_keys", :user => "hadoop"
        has_exec "chmod 644 /home/hadoop/.ssh/authorized_keys", :user => "hadoop"
        has_exec "ssh -o 'StrictHostKeyChecking no' localhost echo", :user => "hadoop" # verify the host key
      end

      def build
        has_directory "/usr/local/src"
        has_exec "wget http://mirror.candidhosting.com/pub/apache/hadoop/core/hadoop-0.19.1/hadoop-0.19.1.tar.gz -O /usr/local/src/hadoop-0.19.1.tar.gz", 
          :not_if => "test -e /usr/local/src/hadoop-0.19.1.tar.gz"
        has_exec "cd /usr/local/src && tar -xzf hadoop-0.19.1.tar.gz",
          :not_if => "test -e #{hadoop_install_dir}"
        has_exec "mv /usr/local/src/hadoop-0.19.1 /usr/local/src/hadoop",
          :not_if => "test -e #{hadoop_install_dir}"
        has_exec "chown -R hadoop:hadoop /usr/local/src/hadoop",
          :not_if => "test -e #{hadoop_install_dir}"
        has_exec "mv /usr/local/src/hadoop #{hadoop_install_dir}",
          :not_if => "test -e #{hadoop_install_dir}"
      end

      def hadoop_install_dir
        "/usr/local/hadoop"
      end

      def configure
        has_file(:name => hadoop_install_dir/"conf/hadoop-env.sh") do
          mode 0644
          template :plugins/:hadoop/:templates/"hadoop-env.sh"
        end
        has_file(:name => hadoop_install_dir/"conf/hadoop-site.xml") do
          mode 0644
          template :plugins/:hadoop/:templates/"hadoop-site.xml"
        end
     end

      def format_hdfs
        has_directory "/usr/local/hadoop-datastore/hadoop-hadoop", :mode => "770"
        has_exec "chown -R hadoop:hadoop /usr/local/hadoop-datastore"

        has_exec "#{hadoop_install_dir}/bin/hadoop namenode -format", 
          :not_if => "test -e /usr/local/hadoop-datastore/hadoop-hadoop/dfs", 
          :user => "hadoop"
      end

      # stuff for examples

      def run_example_job
        start_hadoop
        download_sample_data
        copy_sample_data_to_hdfs
        start_the_job
      end

      def start_hadoop
        has_exec hadoop_install_dir/"bin/start-all.sh", 
          :user => "hadoop"
      end

      def download_sample_data
        has_directory "/tmp/gutenberg", :mode => "770", :owner => "hadoop"
        # todo, create has_wget
        has_exec "wget http://www.gutenberg.org/files/20417/20417.txt -O /tmp/gutenberg/outline-of-science.txt", 
          :not_if => "test -e /tmp/gutenberg/outline-of-science.txt"
        has_exec "wget http://www.gutenberg.org/dirs/etext04/7ldvc10.txt -O /tmp/gutenberg/7ldvc10.txt", 
          :not_if => "test -e /tmp/gutenberg/7ldvc10.txt"
        has_exec "wget http://www.gutenberg.org/files/4300/4300.txt -O /tmp/gutenberg/ulysses.txt",
          :not_if => "test -e /tmp/gutenberg/ulysses.txt"
        has_exec "chown -R hadoop:hadoop /tmp/gutenberg"
      end

      def copy_sample_data_to_hdfs
        has_exec "#{hadoop_install_dir}/bin/hadoop dfs -rmr gutenberg", :user => "hadoop", 
          :only_if => "sudo -H -u hadoop #{hadoop_install_dir}/bin/hadoop dfs -ls gutenberg"
        has_exec "#{hadoop_install_dir}/bin/hadoop dfs -rmr gutenberg-output", :user => "hadoop", 
          :only_if => "sudo -H -u hadoop #{hadoop_install_dir}/bin/hadoop dfs -ls gutenberg-output"
        has_exec "#{hadoop_install_dir}/bin/hadoop dfs -copyFromLocal /tmp/gutenberg gutenberg", 
          :not_if => "sudo -H -u hadoop #{hadoop_install_dir}/bin/hadoop dfs -ls gutenberg | grep ulysses",
          :user => "hadoop"
      end

      def start_the_job
        has_exec "#{hadoop_install_dir}/bin/hadoop jar #{hadoop_install_dir}/hadoop-0.19.1-examples.jar wordcount gutenberg gutenberg-output", 
          :user => "hadoop"
      end

      # open http://192.168.133.128:50070/dfshealth.jsp
      
    end
  end
end
