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
    
    git do
      has_git_repository( :name       => "handkerchief.com",
                          :source     => "git://github.com/auser/xnot.org.git", 
                          :dir        => "/var/www",
                          :owner      => 'www-data')
    end
    apache
    
    has_package "libsqlite3-dev"
    # include_chef_recipe "sqlite"
    
    has_gem_package "rails", :version => "2.3.2"
    has_gem_package "sqlite3-ruby"
    
    # chef do
    #   include_recipes "~/.poolparty/chef/cookbooks/*"
    #   
    #   recipe "#{::File.dirname(__FILE__)}/chef_recipe.rb"
    #   templates "#{::File.dirname(__FILE__)}/templates"
    # end
    
  end

end