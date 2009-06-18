Dir["#{File.dirname(__FILE__)}/plugins/*/*"].each{|l| $:.unshift l }
$:.unshift "/Users/stimble/Code/poolparty-extensions/lib"
require 'rubygems'
require "poolparty"

require 'poolparty-extensions'
require 'plugins/hadoop/hadoop'
require 'plugins/hive/hive'
require 'plugins/convenience_helpers'


pool(:hadoop) do

  cloud(:hadoop_slave) do
    instances 2

    keypair "hadoop_slave"
    using :ec2 do
      security_group ["hadoop"]
    end

    has_convenience_helpers
    has_gem_package("bjeanes-ghost")
    has_gem_package("technicalpickles-jeweler")
    has_development_gem('poolparty-extensions', :from => "~/ruby/poolparty-extensions")

    apache do
      enable_php5
    end

    hadoop do
    end

    ganglia do
    end

  end # cloud :hadoop_slave

  cloud(:hadoop_master) do
    instances 1

    # using :vmrun do
    #   vmx_hash({
    #     "/Users/nmurray/Documents/VMware/Ubuntu-jaunty.vmwarevm/Ubuntu-jaunty.vmx" => "192.168.133.128"
    #   })
    # end

    using :ec2 do
      security_group ["super_open"]
    end
    keypair "hadoop_master"

    has_convenience_helpers
    has_gem_package("bjeanes-ghost")
    has_gem_package("technicalpickles-jeweler")
    has_development_gem('poolparty-extensions', :from => "~/ruby/poolparty-extensions")

    apache do
      enable_php5
    end

    hadoop do
      configure_master
      run_example_job
    end

    hive do
    end

    ganglia do
      master
    end

  end # cloud :hadoop_master

  after_all_loaded do
    # get the master ips on the slaves
    clouds[:hadoop_slave].run_in_context do
      hadoop.perform_just_in_time_operations
    end

    clouds[:hadoop_master].run_in_context do
      hadoop.perform_just_in_time_operations
    end
  end

end # pool

# vim: ft=ruby
