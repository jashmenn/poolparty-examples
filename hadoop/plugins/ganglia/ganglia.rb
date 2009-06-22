=begin rdoc

== Overview
Install Ganglia cloud monitoring system

== Requirements
You'll need apache and php enabled in your clouds.rb. For example:

    apache do
      enable_php5
    end

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

        # libart-2.0-2 ?
        # has_package :name => "libganglia1"
        # has_package :name => "ganglia-monitor"
      end

      def download
        has_exec "wget http://superb-west.dl.sourceforge.net/sourceforge/ganglia/ganglia-3.1.2.tar.gz -O /usr/local/src/ganglia-3.1.2.tar.gz",
          :not_if => "test -e ganglia-3.1.2.tar.gz"
        has_exec "cd /usr/local/src && tar -xvvf /usr/local/src/ganglia-3.1.2.tar.gz",
          :not_if => "test -e /usr/local/src/ganglia-3.1.2"
      end

      def install_webserver_configs
        # hmm
      end

      def master
        has_exec "cd /usr/local/src/ganglia-3.1.2 && ./configure --with-gmetad && make && make install",
          :not_if => "test -e /usr/lib/ganglia"
        has_exec "mv /usr/local/src/ganglia-3.1.2/web /var/www/ganglia",
          :not_if => "test -e /var/www/ganglia"
        gmond
        gmetad
      end

      def slave
        has_exec "cd /usr/local/src/ganglia-3.1.2 && ./configure && make && make install",
          :not_if => "test -e /usr/lib/ganglia"
        gmond
      end

      def gmond
        has_directory "/etc/ganglia"
        has_variable "ganglia_cloud_name", :value => cloud_name 
        has_variable "ganglia_masters_ip", :value => lambda { %Q{\`dig master0 | grep 'SERVER:' | awk -F '[()]' '{ print $2 }'\`.strip}}
        has_file(:name => "/etc/ganglia/gmond.conf") do
          mode 0644
          template :plugins/:ganglia/:templates/"gmond.conf.erb"
        end
        has_exec "/usr/sbin/gmond", :not_if => "ps aux | grep gmond | grep -v grep"
      end

      def gmetad
        has_group "ganglia", :action => :create
        has_user "ganglia", :gid => "ganglia"
        has_directory "/var/lib/ganglia/rrds"
        has_exec "chmod 755 /var/lib/ganglia/rrds"
        has_exec "chown -R ganglia:ganglia /var/lib/ganglia/rrds"

        has_file(:name => "/etc/ganglia/gmetad.conf") do
          mode 0644
          template :plugins/:ganglia/:templates/"gmetad.conf.erb"
        end

        has_exec "/usr/sbin/gmetad", :not_if => "ps aux | grep gmetad | grep -v grep"
      end

      # todo, add a verifier
      # telnet localhost 8649

    end
  end
end


