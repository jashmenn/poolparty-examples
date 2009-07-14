Dir["#{File.dirname(__FILE__)}/plugins/*/*"].each{|l| $:.unshift l }
$:.unshift "#{File.dirname(__FILE__)}/../../poolparty-extensions/lib"
require 'rubygems'
require "poolparty"
require 'poolparty-extensions'
require 'extensions/tripwire/tripwire.rb'
require 'extensions/shorewall/shorewall.rb'

=begin rdoc

== Overview
The beginnings of a security-focused EC2/ubuntu/poolparty image

== Description
Software:

* shorewall  - firewall, very restrictive default settings
* tripwire   - verify file integrity
* denyhosts  - block bruteforce ssh attacks

This setup is not complete by any stretch. 

== PLANS

* Have the file integrity checksums be distributed across the clouds
* Be more specific about if authorized keys + amazon ec2 keys being in
  /var/poolpary and in ~/.ssh/authorized_keys. If we make this more restrictive
  then nodes won't be able to provision each other.

== References

=end



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
</Directory>"
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
      rule "ACCEPT net:10.0.0.0/8 $FW"    # allow local EC2 traffic OR
      rule "ACCEPT net:192.168.0.0/8 $FW" # allow local class C traffic
    end

    denyhosts

  end # cloud :secure

end # pool

# vim: ft=ruby
