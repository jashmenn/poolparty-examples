Dir["#{File.dirname(__FILE__)}/plugins/*/*"].each{|l| $:.unshift l }
$:.unshift "#{File.dirname(__FILE__)}/../../poolparty-extensions/lib"
require 'rubygems'
require "poolparty"

require 'poolparty-extensions'
require 'plugins/hadoop/hadoop'
require 'plugins/hive/hive'
require 'plugins/convenience_helpers'


pool(:cloudteam) do

  cloud(:hadoop_slave) do
    instances 2

    keypair "cloudteam_hadoop_slave"
    using :ec2

    has_convenience_helpers
    has_gem_package("bjeanes-ghost")
    has_gem_package("technicalpickles-jeweler")
    has_development_gem('poolparty-extensions', :from => "#{File.dirname(__FILE__)}/../../poolparty-extensions")

    apache do
      enable_php5
      # todo, write a phpinfo.php verifier
    end

    hadoop do
    end

    ganglia do
      slave
    end

    has_package "nmap"

  end # cloud :hadoop_slave

  cloud(:hadoop_master) do
    instances 1

    # using :vmrun do
    #   vmx_hash({
    #     "/Users/nmurray/Documents/VMware/Ubuntu-jaunty.vmwarevm/Ubuntu-jaunty.vmx" => "192.168.133.128"
    #   })
    # end

    using :ec2
    keypair "cloudteam_hadoop_master"

    has_convenience_helpers
    has_gem_package("bjeanes-ghost")
    has_gem_package("technicalpickles-jeweler")
    has_development_gem('poolparty-extensions', :from => "#{File.dirname(__FILE__)}/../../poolparty-extensions")

    apache do
        has_line_in_file :file => "/etc/apache2/sites-enabled/default", :line => "
<Directory /var/www/>
  Options FollowSymLinks MultiViews
  AllowOverride None
  Order allow,deny
  allow from all
  RedirectMatch ^/\$ /ganglia/
</Directory>"
      enable_php5 do
        extras :gd
      end
    end

    hadoop do
      configure_master
      # run_example_job
    end

    # hive do
    # end

    ganglia do
      monitor "hadoop_slave", "hadoop_master" # what cloud names to monitor
      master
    end

    has_package "nmap"

  end # cloud :hadoop_master

  after_all_loaded do
    # get the master ips on the slaves
    clouds[:hadoop_slave].run_in_context do
      hadoop.perform_just_in_time_operations
      ganglia.perform_after_all_loaded_for_slave
    end

    clouds[:hadoop_master].run_in_context do
      hadoop.perform_just_in_time_operations
      ganglia.perform_after_all_loaded_for_master
    end
  end

end # pool

# vim: ft=ruby
