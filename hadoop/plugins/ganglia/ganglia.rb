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
          configs
        end
      end

      def install_dependencies
        has_package :name => "rrdtool"
        #  libart-2.0-2 ?
        has_package :name => "libganglia1"
        has_package :name => "ganglia-monitor"
      end

      def install_webserver_configs
        # hmm
        # based on: http://linxe-eye.blogspot.com/2008/04/ubuntu-cluster-master-node.html
        # and https://wiki.appnexus.com/display/documentation/Monitoring+Instances+Using+Ganglia
        has_package "librrd-dev"
        has_package "libapr1-dev"
        has_package "libconfuse-dev"
        has_package "python2.6-dev"
        has_exec :command => <<-EOE
        cd /tmp &&
        wget http://superb-west.dl.sourceforge.net/sourceforge/ganglia/ganglia-3.1.2.tar.gz &&
        tar xvzf ganglia*.tar.gz && cd ganglia* &&        
        ./configure --enable-gexec --with-gmetad &&
        make && make install &&
        mkdir /var/www/ganglia &&
        chown -R www-data:www-data /var/www/ganglia &&
        cp -R web/* /var/www/ganglia &&
        cd /tmp && rm -rf /tmp/ganglia* && apache2ctl restart
        EOE
      end

      def master
        has_package :name => "gmetad"        
        install_webserver_configs
      end

      def configs 
        has_variable "ganglia_cloud_name", :value => cloud_name 
        has_file(:name => "/etc/gmond.conf") do
          mode 0644
          template :plugins/:ganglia/:templates/"gmond.conf.erb"
        end
      end

    end
  end
end


