# NOTE: many of the virtual resources below still need to be written
pool(:passenger_site) do
  cloud(:app) do

    # if you want to use ec2 do this:

    # keypair "poolparty-examples"
    # using :ec2

    # if you want to use vmware, try this:
    # replace this with the IP address of your vmware instance
    vmware_ip = "192.168.133.128"

    using :vmrun do
      vmx_hash({
        "/Users/nmurray/Documents/VMware/Ubuntu-jaunty.vmwarevm/Ubuntu-jaunty.vmx" => vmware_ip
      })
    end

    has_package "tree"
    has_package "vim-nox"
    has_package" screen"
    has_package" irb"

    apache do
      install_passenger
      has_passengersite "paparazzi.com", :with_deployment_directories => true do
        has_rails_deploy "paparazzi.com" do
          dir "/var/www"
          migration_command "rake db:schema:load"
          repo "git://github.com/auser/paparazzi.git"
          user "www-data"
          install_sqlite
          # Can also be a relative file path to the database.yml
          database_yml '
# SQLite version 3.x
production:
  adapter: sqlite3
  database: db/production.sqlite3
  pool: 5
  timeout: 5000
          '
        end

      end


 
    end

    verify do
      ping
    end


  end # cloud :app
end # pool

# vim: ft=ruby
