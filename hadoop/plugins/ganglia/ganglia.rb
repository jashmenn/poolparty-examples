=begin rdoc

== Overview
Install Ganglia cloud monitoring system

== Requirements
You'll need apache and php enabled in your clouds.rb. For example:

    apache do
      enable_php5 do
        extras :gd
      end
    end

Because the configs need to know about every node in the cloud *after* it has
launched, you must setup an after_all_loaded block in your clouds.rb that calls
ganglia.perform_after_all_loaded_for_master. For example:

  after_all_loaded do
    clouds[:hadoop_master].run_in_context do
      ganglia.perform_after_all_loaded_for_master
    end
  end

Currently the tasks only need to be run for master, so simply call this on your
"master" cloud. Note: replace hadoop_master with the name of your cloud above.

== References
* http://www.ibm.com/developerworks/wikis/display/WikiPtype/ganglia?decorator=printable
* http://docs.google.com/Doc?id=dgmmft5s_45hr7hmggr
* http://www.hps.com/~tpg/notebook/ganglia.php
* http://www.cultofgary.com/2008/10/16/ec2-and-ganglia/
=end

module PoolParty
  module Plugin
    class Ganglia < Plugin
      def before_load(o={}, &block)
        do_once do
          install_dependencies
          download
        end
      end

      def install_dependencies
        has_package :name => "rrdtool"
        has_package :name => "build-essential"
        has_package :name => "librrd-dev" 
        has_package :name => "libapr1-dev"
        has_package :name => "libconfuse-dev"
        has_package :name => "libexpat1-dev"
        has_package :name => "python-dev"

        has_group "ganglia", :action => :create
        has_user "ganglia", :gid => "ganglia"
 
        # libart-2.0-2 ?
        # has_package :name => "libganglia1"
        # has_package :name => "ganglia-monitor"
      end

      def download
        has_exec "wget http://superb-west.dl.sourceforge.net/sourceforge/ganglia/ganglia-3.1.2.tar.gz -O /usr/local/src/ganglia-3.1.2.tar.gz",
          :not_if => "test -e /usr/local/src/ganglia-3.1.2.tar.gz"
        has_exec "cd /usr/local/src && tar -xvvf /usr/local/src/ganglia-3.1.2.tar.gz",
          :not_if => "test -e /usr/local/src/ganglia-3.1.2"
      end

      def master
        has_exec "cd /usr/local/src/ganglia-3.1.2 && ./configure --with-gmetad && make && make install",
          :not_if => "test -e /usr/lib/ganglia"
        has_exec "mv /usr/local/src/ganglia-3.1.2/web /var/www/ganglia",
          :not_if => "test -e /var/www/ganglia"
        has_file :name => "/var/www/ganglia/conf.php", :mode => "0644", :template => :plugins/:ganglia/:templates/"ganglia-web-conf.php.erb"
        has_variable "ganglia_gmond_is_master", :value => true
        gmond
        gmetad
      end

      def slave
        has_exec "cd /usr/local/src/ganglia-3.1.2 && ./configure && make && make install",
          :not_if => "test -e /usr/lib/ganglia"
        has_variable "ganglia_gmond_is_master", :value => false
        gmond
      end

      def gmond
        has_directory "/etc/ganglia"
        has_exec({:name => "restart-gmond", :command => "/etc/init.d/gmond restart", :action => :nothing})

        has_file(:name => "/etc/init.d/gmond") do
          mode 0755
          template :plugins/:ganglia/:templates/:bin/"gmond.erb"
          calls get_exec("restart-gmond")
        end

        has_service "gmond", :enabled => true, :running => true, :supports => [:restart]
      end

      def gmetad
        has_directory "/var/lib/ganglia/rrds"
        has_exec "chmod 755 /var/lib/ganglia/rrds"
        has_exec "chown -R ganglia:ganglia /var/lib/ganglia/rrds"
        has_exec({:name => "restart-gmetad", :command => "/etc/init.d/gmetad restart", :action => :nothing})
        has_file(:name => "/etc/init.d/gmetad") do
          mode 0755
          template :plugins/:ganglia/:templates/:bin/"gmetad.erb"
          calls get_exec("restart-gmetad")
        end
        has_service "gmetad", :enabled => true, :running => true, :supports => [:restart]
      end

      def monitor(*cloud_names)
        @monitored_clouds = cloud_names
      end

      def perform_after_all_loaded_for_slave
        gmond_after_all_loaded
      end

      def perform_after_all_loaded_for_master
        raise "No clouds to monitor with ganglia specified. Please use the 'monitor(*cloud_names)' directive within your ganglia block" unless @monitored_clouds
        gmond_after_all_loaded

        data_sources = ""
        @monitored_clouds.each do |cloud_name|
          line = "data_source \\\"#{cloud_name}\\\" "
          ips = []
          clouds[cloud_name.intern].nodes(:status => 'running').each_with_index do |n, i|
            ips << n[:private_dns_name] + ":8649"
          end
          data_sources << (line + ips.join(" ") + "\n")
        end
        data_sources.gsub!(/\n/, '\n')

        has_variable "ganglia_gmetad_data_sources", :value => data_sources
        has_file(:name => "/etc/ganglia/gmetad.conf") do
          mode 0644
          template :plugins/:ganglia/:templates/"gmetad.conf.erb"
          # calls get_exec("restart-gmetad")
        end
      end

      def gmond_after_all_loaded
        has_variable "ganglia_cloud_name", :value => cloud_name 
        has_variable "ganglia_this_nodes_private_ip", :value => lambda{ %Q{%x[curl http://169.254.169.254/latest/meta-data/local-ipv4]}}
        has_variable "ganglia_masters_ip", :value => lambda { %Q{\`ping -c1  master0 | grep PING | awk -F '[()]' '{print $2 }'\`.strip}}

        first_node = clouds[cloud_name].nodes(:status => 'running').first
        has_variable "ganglia_first_node_in_clusters_ip", :value => lambda { %Q{\`ping -c1  #{first_node[:private_dns_name]} | grep PING | awk -F '[()]' '{print $2 }'\`.strip}}

        has_file(:name => "/etc/ganglia/gmond.conf") do
          mode 0644
          template :plugins/:ganglia/:templates/"gmond.conf.erb"
          # calls get_exec("restart-gmond")
        end

      end

      # todo, add a verifier
      # telnet localhost 8649

    end
  end
end


