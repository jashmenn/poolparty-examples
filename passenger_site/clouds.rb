# NOTE: many of the virtual resources below still need to be written
pool(:passenger_site) do
  cloud(:app) do

    # if you want to use ec2 do this:

    # keypair "poolparty-examples"
    # using :ec2

    # if you want to use vmware, try this:
    # replace this with the IP address of your vmware instance
    vmware_ip = "192.168.248.133"
    
    keypair "id_rsa"
    
    using :vmware do
      image_id "/Users/alerner/Documents/vm/Ubuntu32bitVM.vmwarevm/Ubuntu32bitVM.vmx"
      public_ip vmware_ip
    end

    has_package "tree"
    has_package "vim-nox"
    has_package" screen"
    has_package" irb"

    apache do
      install_passenger
      has_passenger_site "sample_app.com", :with_deployment_directories => true
      install_site("sample_app.com", :no_file => true)
    end

  end # cloud :app
end # pool

# vim: ft=ruby
