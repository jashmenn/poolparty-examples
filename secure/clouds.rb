Dir["#{File.dirname(__FILE__)}/plugins/*/*"].each{|l| $:.unshift l }
$:.unshift "#{File.dirname(__FILE__)}/../../poolparty-extensions/lib"
require 'rubygems'
require "poolparty"
require 'poolparty-extensions'
require 'extensions/tripwire/tripwire.rb'
require 'extensions/shorewall/shorewall.rb'

pool(:cloud) do

  cloud(:secure) do
    instances 1

    using :vmrun do
      vmx_hash({
        "/Users/nmurray/Documents/VMware/Ubuntu-jaunty.vmwarevm/Ubuntu-jaunty.vmx" => "192.168.133.128"
      })
    end

    # using :ec2 do
    #   security_group [SECURITY_GROUP]
    # end

    # keypair "#{KEYPAIR_PREFIX}_master"

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

    has_package "nmap"
    has_package "git-core"

    tripwire do
      root_dir "/usr/wpt" # CHANGE THIS to something obscure. The idea is you *dont* want tripwire to be in a standard location.
      mailto   "admin@emaildomain"
      smtp_settings "host", "username", "password"
    end

    shorewall do
      rule "Web/ACCEPT net $FW"
      rule "SSH/ACCEPT net $FW"
    end

    has_package "denyhosts"

  end # cloud :hadoop_master

  after_all_loaded do
    # get the master ips on the slaves
    # clouds[:hadoop_slave].run_in_context do
    #   hadoop.perform_just_in_time_operations
    #   ganglia.perform_after_all_loaded_for_slave
    # end

    # clouds[:hadoop_master].run_in_context do
    #   hadoop.perform_just_in_time_operations
    #   ganglia.perform_after_all_loaded_for_master
    # end
  end

end # pool


# vim: ft=ruby
