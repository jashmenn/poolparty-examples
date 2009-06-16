require 'poolparty-extensions'
require 'plugins/hadoop/hadoop'
require 'plugins/convenience_helpers'

pool(:hadoop_cluster) do

  cloud(:hadoop_slave) do
    instances 1

    using :ec2
    keypair "nmurray-hadoop-slave"
    has_convenience_helpers

    hadoop do
      # run_example_job
    end

    # clouds[:hadoop_master].nodes(:status => 'running').each_with_index do |n, i|
    #   has_host(:name => "master#{i}", :ip => n.public_ip) 
    # end

  end # cloud :hadoop_slave

  cloud(:hadoop_master) do
    instances 1

    # using :vmrun do
    #   vmx_hash({
    #     "/Users/nmurray/Documents/VMware/Ubuntu-jaunty.vmwarevm/Ubuntu-jaunty.vmx" => "192.168.133.128"
    #   })
    # end

    using :ec2
    keypair "nmurray-hadoop-master"
    has_convenience_helpers

    hadoop do
      configure_master
    end

    # todo, this should be a list of all the masters
    has_host(:name => "master0", :ip => "127.0.0.1")
    clouds[:hadoop_slave].nodes(:status => 'running').each_with_index do |n, i|
      has_host(:name => "slave#{i}", :ip => n.public_ip) 
    end

  end # cloud :hadoop_master


end # pool

# vim: ft=ruby
