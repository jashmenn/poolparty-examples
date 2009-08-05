# Basic pool spec
# Shows global settings for the clouds
# require "poolparty-extensions"

pool :application do
  instances 1..3
  
  cloud :pp2 do
    # replace this with the IP address of your vmware instance
    keypair "id_rsa"
    
    using :vmware do
      image_id "/Users/alerner/Documents/vm/Ubuntu32bitVM.vmwarevm/Ubuntu32bitVM.vmx"
      public_ip "192.168.248.133"
    end
    
    # git do
    #   has_git_repository( :name       => "paparazzi.com",
    #                       :source     => "git://github.com/auser/paparazzi.git", 
    #                       :dir        => "/var/www/paparazzi",
    #                       :owner      => 'www-data')
    # end
    
    has_directory "/var/log"
    has_file "/etc/motd"    
    
    rails do
      deployer_user "deployer"
      app "paparazzi.com" do
        on :passenger
        at "/var/www"
      end
    end
    
    has_file "/var/www/index.html"
    
  end

end