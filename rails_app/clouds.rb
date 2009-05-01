# Basic pool spec
# Shows global settings for the clouds
require "poolparty-extensions"

pool :application do
  instances 1..3
  
  cloud :pp2 do    
    enable :haproxy, :git
    
    has_package "libsqlite3-dev"
    include_chef_recipe "sqlite"
    
    has_gem_package "rails", :version => "2.3.2"
    has_gem_package "sqlite3-ruby"
    
    has_rails_deploy "paparazzi" do
      dir "/var/www"
      migration_command "rake db:schema:load"
      repo "git://github.com/auser/paparazzi.git"
      user "www-data"
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
    
    chef do
      include_recipes "~/.poolparty/chef/cookbooks/*"
      
      recipe "chef_recipe.rb"
      templates "templates/"
    end
    
    verify do
      ping 80
    end
    
  end

end