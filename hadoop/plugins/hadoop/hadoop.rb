=begin rdoc

== Overview
Install a hadoop cluster

== Requirements
You'll need apache and php enabled in your clouds.rb. For example:

    apache do
      enable_php5
    end

== Bugs
This assumes your clouds are named "hadoop_master" and "hadoop_slave". That sucks. TODO: pass these in as variables

== References
=end



module PoolParty
  module Plugin
    class Hadoop < Plugin
      def before_load(o={}, &block)
        do_once do
          install_jdk
          # add_users_and_groups
          create_keys
          connect_keys
          build
          configure
          format_hdfs
          create_aliases
        end
      end

      def perform_just_in_time_operations
        create_reference_hosts
        create_ssh_configs
        create_master_and_slaves_files
      end

      def install_jdk
        # accept the sun license agreements. see: http://www.davidpashley.com/blog/debian/java-license
        has_exec "echo sun-java6-jdk shared/accepted-sun-dlj-v1-1 select true | /usr/bin/debconf-set-selections"
        has_exec "echo sun-java6-jre shared/accepted-sun-dlj-v1-1 select true | /usr/bin/debconf-set-selections"
        has_package(:name => "sun-java6-jdk")
        has_file(:name => "/etc/jvm") do
            mode 0644
            template "jvm.conf"
         end
      end

      def add_users_and_groups
        has_group "hadoop", :action => :create
        has_user "hadoop", :gid => "hadoop"
        has_directory "/home/hadoop", :owner => "hadoop", :mode => "755"

        # TODO - ssh key code below needs to turn into these lines. those should become plugins
        # has_ssh_key :user => "hadoop", :name => "hadoop_id_rsa", :create => true
        # has_authorized_key :user => "hadoop", :name => "hadoop_id_rsa"
      end

      def create_keys
        unless File.exists?(hadoop_id_rsa)
          FileUtils.mkdir_p(cloud_keys_dir)
          cmd = "ssh-keygen -t rsa -N '' -f #{hadoop_id_rsa}" # todo, make into variables
          puts cmd
          `#{cmd}`
        end
      end

      # everything below should become methods and/or plugins
      def connect_keys
        # has_exec "ssh-keygen -t rsa -N '' -f /home/hadoop/.ssh/id_rsa", :user => "hadoop", :not_if => "test -e /home/hadoop/.ssh/id_rsa"

        # so annoying, chef/rsync/something doesn't copy over dotfiles, so upload it as non-dot
        has_directory :name => "#{home_dir}/ssh"
        has_directory :name => "#{home_dir}/.ssh"
        has_file :name => "#{home_dir}/ssh/#{hadoop_id_rsa_base}", :content => open(hadoop_id_rsa).read
        has_exec "mv #{home_dir}/ssh/hadoop_id_rsa #{home_dir}/.ssh/#{hadoop_id_rsa_base}"
        has_exec "chmod 600 #{home_dir}/.ssh/#{hadoop_id_rsa_base}"
        has_exec "chmod 700 #{home_dir}/.ssh"
        has_exec "rm -rf #{home_dir}/ssh"

        # setup authorized keys
        has_exec "touch #{home_dir}/.ssh/authorized_keys"
        has_exec "chmod 644 #{home_dir}/.ssh/authorized_keys"
        has_exec "chown -R #{user} #{home_dir}/.ssh"
        has_line_in_file :file => "#{home_dir}/.ssh/authorized_keys", :line => File.read("#{hadoop_id_rsa}.pub")
      end

      def create_reference_hosts
        clouds[:hadoop_master].nodes(:status => 'running').each_with_index do |n, i|
          # has_host(:name => "master#{i}", :ip => n.public_ip)  # todo
          # my_line_in_file("/etc/hosts", "#{n.public_ip} master#{i}")
          has_exec "ghost modify master#{i} \`dig +short #{n[:private_dns_name]}\`"
        end
        clouds[:hadoop_slave].nodes(:status => 'running').each_with_index do |n, i|
          # has_host(:name => "slave#{i}", :ip => n.public_ip)  # todo
          # my_line_in_file("/etc/hosts", "#{n.public_ip} slave#{i}")
          has_exec "ghost modify slave#{i} \`dig +short #{n[:private_dns_name]}\`"
        end
      end

      def create_ssh_configs
        ssh_config = ""
        clouds[:hadoop_master].nodes(:status => 'running').each_with_index do |n,i| 
          has_exec "ssh -o 'StrictHostKeyChecking no' -i #{home_dir}/.ssh/#{hadoop_id_rsa_base} master#{i} echo", :user => user # verify the host key
        end 

        clouds[:hadoop_slave].nodes(:status => 'running').each_with_index do |n,i| 
          has_exec "ssh -o 'StrictHostKeyChecking no' -i #{home_dir}/.ssh/#{hadoop_id_rsa_base} slave#{i} echo", :user => user # verify the host key
        end 

        ssh_config << <<EOF
Host *
       IdentityFile #{home_dir}/.ssh/#{hadoop_id_rsa_base}
EOF
        has_exec "ssh -o 'StrictHostKeyChecking no' -i #{home_dir}/.ssh/#{hadoop_id_rsa_base} localhost echo", :user => user # verify the host key

        has_file("#{home_dir}/ssh_config", :content => ssh_config)
        has_exec "mv #{home_dir}/ssh_config #{home_dir}/.ssh/config"
        has_exec "chmod 600 #{home_dir}/.ssh/config"
        has_exec "chown #{user}:#{group} #{home_dir}/.ssh/config"
      end

      def build
        has_directory "/usr/local/src"
        has_exec "wget http://www.gossipcheck.com/mirrors/apache/hadoop/core/hadoop-0.20.0/hadoop-0.20.0.tar.gz -O /usr/local/src/hadoop-0.20.0.tar.gz", 
          :not_if => "test -e /usr/local/src/hadoop-0.20.0.tar.gz"
        has_exec "cd /usr/local/src && tar -xzf hadoop-0.20.0.tar.gz",
          :not_if => "test -e #{hadoop_install_dir}"
        has_exec "mv /usr/local/src/hadoop-0.20.0 /usr/local/src/hadoop",
          :not_if => "test -e #{hadoop_install_dir}"
        has_exec "chown -R #{user}:#{group} /usr/local/src/hadoop",
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
          template "hadoop-env.sh"
        end

        has_variable "current_master", :value => "master0" # todo, could eventually be made more dynamic here

        # puts "we have this many nodes in our pool: #{number_of_running_nodes_in_pool}"
        # has_variable "number_of_nodes", :value => lambda { %Q{ %x[/usr/bin/cloud-list --short].split("\\n").size || 1 }}
        has_variable "number_of_nodes", :value => 2 # todo

        has_directory hadoop_data_dir, :owner => user, :mode => "755"
        has_exec "chgrp -R #{group} #{hadoop_data_dir}"

        %w{logs name data mapred temp}.each do |folder|
          has_directory hadoop_data_dir/folder, :owner => user, :mode => "755"
        end
        has_directory hadoop_data_dir/:temp/:dfs/:data, :owner => user, :mode => "755"

        %w{local system temp}.each do |folder|
          has_directory hadoop_data_dir/:temp/:mapred/folder, :owner => user, :mode => "755"
        end

        has_variable "hadoop_data_dir",   :value => hadoop_data_dir
        has_variable "hadoop_mapred_dir", :value => hadoop_data_dir/:mapred

        has_variable("hadoop_this_nodes_ip", :value => lambda{ %Q{%x[curl http://169.254.169.254/latest/meta-data/local-ipv4]}})

        %w{core hdfs mapred}.each do |config|
          has_file(:name => hadoop_install_dir/"conf/#{config}-site.xml") do
            mode 0644
            template "#{config}-site.xml.erb"
          end
        end

        has_file(:name => hadoop_install_dir/"conf/log4j.properties") do
          mode 0644
          template "log4j.properties.erb"
        end

     end

     def number_of_running_nodes_in_pool
       # clouds.keys.inject(0) { |sum,cloud_name| sum = sum + clouds[cloud_name].nodes(:status => 'running').size; sum }
     end

     def configure_master
       # create_master_and_slaves_files
     end

     def format_hdfs
       has_directory hadoop_data_dir, :mode => "770"
       has_exec "chown -R #{user}:#{group} #{hadoop_data_dir}"

       has_exec "#{hadoop_install_dir}/bin/hadoop namenode -format", 
         # :not_if => "test -e #{hadoop_data_dir}/hadoop-hadoop/dfs", 
         :not_if => "test -e #{hadoop_data_dir}/dfs/name",  # this line depends on if you have user-based data directories in core-site.xml
         :user => user
     end

     # stuff for examples

     def run_example_job
       start_hadoop
       download_sample_data
       # copy_sample_data_to_hdfs
       # start_the_job
     end

     def start_hadoop
       has_exec hadoop_install_dir/"bin/start-all.sh", 
         :user => user
     end

     def download_sample_data
       has_directory "/tmp/gutenberg", :mode => "770", :owner => user
       # todo, create has_wget
       has_exec "wget http://www.gutenberg.org/files/20417/20417.txt -O /tmp/gutenberg/outline-of-science.txt", 
         :not_if => "test -e /tmp/gutenberg/outline-of-science.txt"
       has_exec "wget http://www.gutenberg.org/dirs/etext04/7ldvc10.txt -O /tmp/gutenberg/7ldvc10.txt", 
         :not_if => "test -e /tmp/gutenberg/7ldvc10.txt"
       has_exec "wget http://www.gutenberg.org/files/4300/4300.txt -O /tmp/gutenberg/ulysses.txt",
         :not_if => "test -e /tmp/gutenberg/ulysses.txt"
       has_exec "chown -R #{user}:#{group} /tmp/gutenberg"
     end

     def copy_sample_data_to_hdfs
       has_exec "#{hadoop_install_dir}/bin/hadoop dfs -rmr gutenberg", :user => user,
         :only_if => "sudo -H -u #{user} #{hadoop_install_dir}/bin/hadoop dfs -ls gutenberg"
       has_exec "#{hadoop_install_dir}/bin/hadoop dfs -rmr gutenberg-output", :user => user, 
         :only_if => "sudo -H -u #{user} #{hadoop_install_dir}/bin/hadoop dfs -ls gutenberg-output"
       has_exec "#{hadoop_install_dir}/bin/hadoop dfs -copyFromLocal /tmp/gutenberg gutenberg", 
         :not_if => "sudo -H -u #{user} #{hadoop_install_dir}/bin/hadoop dfs -ls gutenberg | grep ulysses",
         :user => user
     end

     def start_the_job
       has_exec "#{hadoop_install_dir}/bin/hadoop jar #{hadoop_install_dir}/hadoop-0.20.0-examples.jar wordcount gutenberg gutenberg-output", 
         :user => user
     end

     def create_master_and_slaves_files
       masters_file = ""
       slaves_file  = ""

       clouds[:hadoop_master].nodes(:status => 'running').each_with_index do |n,i| 
         masters_file << "master#{i}\n"
         # slaves_file  << "master#{i}\n" # our masters are also slaves
       end 

       clouds[:hadoop_slave].nodes(:status => 'running').each_with_index do |n, i|
         slaves_file << "slave#{i}\n"
       end

       has_file(hadoop_install_dir/:conf/:masters, :content => masters_file)
       has_file(hadoop_install_dir/:conf/:slaves,  :content => slaves_file)
     end

     def create_aliases
        has_bash_alias :name => "cd-hadoop", :value => "pushd /usr/local/hadoop"
     end

      private
      def cloud_keys_dir
        File.dirname(pool_specfile)/:keys
      end

      def hadoop_id_rsa
        "#{cloud_keys_dir}/#{hadoop_id_rsa_base}" 
      end

      def hadoop_id_rsa_base
        "hadoop_id_rsa"
      end

      def hadoop_data_dir
        "/mnt/hadoop-data"
      end

      def home_dir
        "/root" 
        # or
        # "/home/hadoop"
      end

      def user
        "root"
        # or
        # hadoop
      end

      def group
        "root"
        # or
        # hadoop
      end

      def my_line_in_file(file, line)
        has_exec "line_in_#{file}_#{line.safe_quote}" do
          command "grep -q \'#{line.safe_quote}\' #{file} || echo \'#{line.safe_quote}\' >> #{file}"
          not_if "grep -q \'#{line.safe_quote}\' #{file}"
        end
      end
      
    end
  end
end
