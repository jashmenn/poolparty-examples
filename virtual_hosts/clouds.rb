pool(:adams) do
  cloud(:app) do

    # replace this with the IP address of your vmware instance
    keypair "id_rsa"
    
    using :vmware do
      image_id "/Users/alerner/Documents/vm/Ubuntu32bitVM.vmwarevm/Ubuntu32bitVM.vmx"
      public_ip "192.168.248.133"
    end

    instances 1

    has_package "tree"
    has_package "vim-nox"

    apache do
      enable_default
      
      has_file "/var/www/index.html" do
        content "<h1>Welcome to your new poolparty instance</h1>"
        mode 0644
        owner "www-data"
      end
      
      has_virtual_host "handkerchief.com" do
      
        has_file :name => "/var/www/handkerchief.com/index.html" do
          content "<h1>Welcome to handkerchief.com</h1>"
          mode "0644"
          owner "www-data"
        end
      end
      
      has_virtual_host "tissues.com" do
      
        has_file :name => "/var/www/tissues.com/index.html" do
          content "<h1>Welcome to tissues.com</h1>"
          mode 0644
          owner "www-data"
        end
      end  

    end

  end # cloud :app
end # pool

# vim: ft=ruby
