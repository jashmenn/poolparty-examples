Dir["#{File.dirname(__FILE__)}/plugins/*/*"].each{|l| $:.unshift l }
$:.unshift "#{File.dirname(__FILE__)}/../../poolparty-extensions/lib"
require 'rubygems'
require "poolparty"
require 'poolparty-extensions'

KEYPAIR_PREFIX = "cloud_hadoop"
SECURITY_GROUP = "hadoop_pool"
# KEYPAIR_PREFIX = "cloudteam_hadoop"
# SECURITY_GROUP = "nmurray-hadoop"

pool(:cloud) do

  cloud(:hadoop_slave) do
    instances 3

    keypair "#{KEYPAIR_PREFIX}_slave"
    using :ec2 do
      security_group [SECURITY_GROUP]
    end

    has_convenience_helpers
    has_gem_package("bjeanes-ghost")
    has_gem_package("technicalpickles-jeweler")
    has_development_gem('poolparty-extensions', :from => "#{File.dirname(__FILE__)}/../../poolparty-extensions")

    apache do
      enable_php5 # todo, write a phpinfo.php verifier
    end

    hadoop do
      configure_slave
    end

    ganglia do
      slave
      track :hadoop
    end

    has_package "nmap"

    tripwire do
      root_dir "/usr/wpt" # CHANGE THIS to something obscure. The idea is you *dont* want tripwire to be in a standard location.
      mailto   "admin@emaildomain"
      smtp_settings "host", "username", "password"
    end

    shorewall do
      rule "Web/ACCEPT net $FW"
      rule "SSH/ACCEPT net $FW"
      rule "ACCEPT net:10.0.0.0/8 $FW"    # allow local EC2 traffic OR
    end
    denyhosts

  end # cloud :hadoop_slave

  cloud(:hadoop_master) do
    instances 1

    # using :vmrun do
    #   vmx_hash({
    #     "/Users/nmurray/Documents/VMware/Ubuntu-jaunty.vmwarevm/Ubuntu-jaunty.vmx" => "192.168.133.128"
    #   })
    # end

    using :ec2 do
      security_group [SECURITY_GROUP]
    end

    keypair "#{KEYPAIR_PREFIX}_master"

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
      prep_example_job
      # run_example_job
      create_client_user('hadoop_client') # NOTE! this creates a hadoop_client user! no password 
                                          # login or authorized keys though, just thought you should know
    end

    hive do
      has_package "ant"
      has_package "jruby1.1"
      # need to buid jdbc jar?
      has_gem_package "sequel", :jruby => true
    end

    ganglia do
      monitor "hadoop_slave", "hadoop_master" # what cloud names to monitor
      master
      # other things id like to monitor:
    end

    has_package "nmap"
    has_package "git-core"

    # for internal log processing scripts
    has_gem_package "ruby-debug"
    has_gem_package "sequel" # not jruby as above
    has_package "libsqlite3-dev"
    has_gem_package "sqlite3-ruby"

    tripwire do
      root_dir "/usr/wpt" # CHANGE THIS to something obscure. The idea is you *dont* want tripwire to be in a standard location.
      mailto   "admin@emaildomain"
      smtp_settings "host", "username", "password"
    end

    shorewall do
      rule "Web/ACCEPT net $FW"
      rule "SSH/ACCEPT net $FW"
      rule "ACCEPT net:10.0.0.0/8 $FW"    # allow local EC2 traffic OR
    end
    denyhosts

    mysql do
      master
      root_password "angrybobby123"
      database do
        create_database "hive_metastore" 
        grant_permissions_on_cloud_with_keypair_for_user "cloudteam_hadoop_master", "bobby", "abbyzabby17"
      end
    end

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
