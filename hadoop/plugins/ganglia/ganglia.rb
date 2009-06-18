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
        has_package :name => "libganglia1"
        has_package :name => "ganglia-monitor"
      end

      def install_webserver_configs
        # hmm
      end

      def configs 
        has_variable "ganglia_cloud_name", :value => name
        has_file(:name => "/etc/gmond.conf") do
          mode 0644
          template :plugins/:ganglia/:templates/"gmond.conf.erb"
        end
      end

    end
  end
end


