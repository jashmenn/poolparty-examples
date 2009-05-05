pool(:adams) do
  cloud(:app) do

    # replace this with the IP address of your vmware instance
    vmware_ip = "192.168.133.128"

    using :vmrun do
      vmx_hash({
        "/Users/nmurray/Documents/VMware/Ubuntu-jaunty.vmwarevm/Ubuntu-jaunty.vmx" => vmware_ip
      })
    end

    instances 1
    # enable :haproxy
    has_package "tree"

    apache do
      enable_default
      has_file :name => "/var/www/index.html" do
        content "<h1>Welcome to your new poolparty instance</h1>"
        mode 0644
        owner "www-data"
      end


      has_virtualhost do
        name "handkerchief.com"

        has_file :name => "/var/www/handkerchief.com/index.html" do
          content "<h1>Welcome to handkerchief.com</h1>"
          mode 0644
          owner "www-data"
        end
      end

      has_virtualhost do
        name "tissues.com"

        has_file :name => "/var/www/tissues.com/index.html" do
          content "<h1>Welcome to tissues.com</h1>"
          mode 0644
          owner "www-data"
        end
      end

    end

    verify do
      ping
      http_status "http://#{vmware_ip}/index.html", 200
      http_match  "http://#{vmware_ip}/index.html", /Welcome to your new poolparty instance/

      http_status "http://handkerchief.com", 200
      http_match  "http://handkerchief.com", /Welcome to handkerchief.com/

      http_status "http://tissues.com", 200
      http_match  "http://tissues.com", /Welcome to tissues.com/
    end


    # below is the eventual apache config
    
    # apache do
      # installed_as_standard

      # enable_php5 do
      #   extras :cli, :pspell, :mysql
      # end

      # config("store", ::File.join(File.dirname(__FILE__), "templates/apache", "store.conf.erb"))

      # has_custom_store do
      #   name "my_store.com"
      # end

      # has_file({:name => "/etc/apache2/htpasswd", 
      #         :template => File.dirname(__FILE__) + "/templates/apache/htpasswd",
      #         :owner => "www-data",
      #         :group => "www-data",
      #         :mode => 660})

      # present_apache_module("speling")
      # has_file({:name => "/etc/apache2/mods-enabled/speling.conf", 
      #             :content => "CheckSpelling On",
      #             :owner => "www-data",
      #             :group => "www-data",
      #             :mode => 660})

    # end

  end # cloud :app
end # pool

# vim: ft=ruby
