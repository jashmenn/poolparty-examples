# BEEE YOURSELF!
node[:apache][:dir] = "/etc/apache2"
node[:passenger][:version] = "2.2.2"
node[:rails][:version] = "2.3.2"

include_recipe "rails"
include_recipe "apache2::mod_rails"
include_recipe "sqlite"
 
gem_package "sqlite3-ruby"
gem_package "rake" do
  version "0.8.4"
end
 
web_app "paparazzi" do
  docroot "/var/www/paparazzi/current/public"
  template "paparazzi.conf.erb"
  server_name "www.paparazzi.com"
  server_aliases [node[:hostname], node[:fqdn], "paparazzi.com"]
  rails_env "production"
end
