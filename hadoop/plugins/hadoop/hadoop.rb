=begin rdoc
=end

module PoolParty
  module Plugin
    class Hadoop < Plugin
      def loaded(*args)
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
        has_group "hadoop"
        has_user "hadoop", :group => "hadoop"
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

        has_exec "sudo -H -u hadoop #{hadoop_install_dir}/bin/hadoop namenode -format", 
          :not_if => "test -e /usr/local/hadoop-datastore/hadoop-hadoop/dfs"
      end

    end
  end
end
