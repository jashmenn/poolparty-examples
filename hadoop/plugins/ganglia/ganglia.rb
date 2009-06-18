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
        end
      end

      def install_dependencies
        has_package :name => "rrdtool"
      end

      def install_webserver_configs
        # hmm
      end
    end
  end
end


