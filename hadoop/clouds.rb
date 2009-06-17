require 'poolparty-extensions'
require 'plugins/hadoop/hadoop'
require 'plugins/convenience_helpers'

pool(:hadoop_cluster) do

  cloud(:hadoop_slave) do
    instances 1

    keypair "nmurray-hadoop-slave"
    using :ec2 do
      security_group ["nmurray-hadoop"]
    end

    has_convenience_helpers
    has_gem_package("bjeanes-ghost")
    has_gem_package("technicalpickles-jeweler")
    has_development_gem('poolparty-extensions', :from => "~/ruby/poolparty-extensions")

    hadoop do
      # run_example_job
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
      security_group ["nmurray-hadoop"]
    end
    keypair "nmurray-hadoop-master"

    has_convenience_helpers
    has_gem_package("bjeanes-ghost")
    has_gem_package("technicalpickles-jeweler")
    has_development_gem('poolparty-extensions', :from => "~/ruby/poolparty-extensions")

    hadoop do
      configure_master
    end

    # todo, this should be a list of all the masters
    # has_host(:name => "master0", :ip => "127.0.0.1")

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
