=begin rdoc
In
=end

module PoolParty
  module Plugin
    class Hive < Plugin
      def before_load(o={}, &block)
        do_once do
          install_from_bin
          set_environment_variables
          create_hdfs_directories
        end
      end

      def install_from_bin
        has_exec "wget #{hive_dist} -O /usr/local/src/hive-0.3.0-hadoop-0.19.0-dev.tar.gz",
          :not_if => "test -e /usr/local/src/hive-0.3.0-hadoop-0.19.0-dev.tar.gz"
        has_exec "cd /usr/local/src && tar -xvvf /usr/local/src/hive-0.3.0-hadoop-0.19.0-dev.tar.gz", 
          :not_if => "test -e #{hive_home}"
        has_exec "mv /usr/local/src/hive-0.3.0-hadoop-0.19.0-dev #{hive_home}", 
          :not_if => "test -e #{hive_home}"
      end

      # doesn't really work
      def install_from_src
        install_dependent_packages
        download_and_build_src
      end

      def install_dependent_packages
        has_package :name => "subversion"
        has_package :name => "ant"
      end

      def download_and_build_src
        has_exec "svn co #{hive_repo} #{src_dir}",
          :not_if => "test -e #{src_dir}/build.xml"
        has_exec "cd #{src_dir} && ant -Dhadoop.version=\\\"#{hadoop_version}\\\" package",
          :not_if => "test -e #{src_dir}/build/dist/README.txt"
      end


      def tmp
        "svn co http://svn.apache.org/repos/asf/hadoop/hive/trunk hive -r781069"
        "cd /usr/local/hive && wget --no-check-certificate https://issues.apache.org/jira/secure/attachment/12409779/hive-487.3.patch"
        "root@domU-12-31-38-00-41-F5 18:38 /usr/local/src/hive (hadoop_master) $ patch -p0 < hive-487.3.patch"
        "rm -rf /usr/local/hive"
        "mv /usr/local/src/hive/build/dist/ /usr/local/hive"
      end

      # todo, pull from parent
      def set_environment_variables
        has_file :name => "/root/.hadoop-etc-env.sh", :content => <<-EOF
export HADOOP_HOME=#{hadoop_home}
export HADOOP=$HADOOP_HOME/bin/hadoop
export HIVE_HOME=#{hive_home}
export PATH=$HADOOP_HOME/bin:$HIVE_HOME/bin:$PATH
        EOF
        has_line_in_file :file => "/root/.profile", :line => "source /root/.hadoop-etc-env.sh"
      end

      def create_hdfs_directories
        has_exec "#{hadoop_home}/bin/hadoop fs -mkdir /tmp", 
          :not_if => "#{hadoop_home}/bin/hadoop fs -ls /tmp"
 
        has_exec "#{hadoop_home}/bin/hadoop fs -mkdir /user/hive/warehouse", 
          :not_if => "#{hadoop_home}/bin/hadoop fs -ls /user/hive/warehouse"

        has_exec "#{hadoop_home}/bin/hadoop fs -chmod g+w /tmp", 
          :not_if => "#{hadoop_home}/bin/hadoop fs -ls /tmp" # todo, check perms
 
        has_exec "#{hadoop_home}/bin/hadoop fs -chmod g+w /user/hive/warehouse", 
          :not_if => "#{hadoop_home}/bin/hadoop fs -ls /user/hive/warehouse"
      end

      private

      def hive_dist
        "http://www.apache.org/dist/hadoop/hive/hive-0.3.0/hive-0.3.0-hadoop-0.19.0-dev.tar.gz"
      end

      def src_dir
        "/usr/local/src/hive"
      end

      def hive_home
        "/usr/local/hive"
      end

      def hive_repo
        # "http://svn.apache.org/repos/asf/hadoop/hive/trunk"
        "http://svn.apache.org/repos/asf/hadoop/hive/tags/release-0.3.0/"
      end

      ### should pull from parent
      def hadoop_home
        "/usr/local/hadoop"
      end

      # would be really awesome if this was a variable in the hadoop plugin and
      # this called out to it via parent. todo
      def hadoop_version
        "0.20.0"
      end



    end
  end
end
 
