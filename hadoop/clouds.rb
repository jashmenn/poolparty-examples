require 'plugins/hadoop/hadoop'
require 'poolparty-extensions'

pool(:hadoop_cluster) do
  cloud(:hadoop_master) do
    instances 1

    # using :vmrun do
    #   vmx_hash({
    #     "/Users/nmurray/Documents/VMware/Ubuntu-jaunty.vmwarevm/Ubuntu-jaunty.vmx" => "192.168.133.128"
    #   })
    # end

    using :ec2
    keypair "nmurray-hadoop-master"
    # keypair "hadoop-master"
 

    has_package "tree"
    has_package "vim-nox"
    has_package" screen"
    has_package" irb"
    has_bash_alias "inspect-poolparty-recipes", :value => "vi /var/poolparty/dr_configure/chef/cookbooks/poolparty/recipes/default.rb"

    hadoop do
      # run_example_job
    end

    has_host(:name => "master", :ip => "127.0.0.1")
    # clouds[:hadoop_slave].nodes(:status => 'running').each_with_index do |n, i|
    #   has_host(:name => "slave#{i}", :ip => n.public_ip) 
    # end

  end # cloud :hadoop_master

  cloud(:hadoop_slave) do
    instances 1

    using :ec2
    keypair "nmurray-hadoop-slave"
    # keypair "hadoop-slave"

    has_package "tree"
    has_package "vim-nox"
    has_package" screen"
    has_package" irb"
    has_bash_alias "inspect-poolparty-recipes", :value => "vi /var/poolparty/dr_configure/chef/cookbooks/poolparty/recipes/default.rb"

    hadoop do
      # run_example_job
    end

    clouds[:hadoop_master].nodes(:status => 'running').each_with_index do |n, i|
      has_host(:name => "master#{i}", :ip => n.public_ip) 
    end

  end # cloud :hadoop_slave

end # pool

# vim: ft=ruby
