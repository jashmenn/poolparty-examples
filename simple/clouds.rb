# Basic poolparty template

pool :poolparty do
  cloud :app do
    instances 2..5
  end
  
  enable :haproxy # enables apache
  
  has_file :name => "/var/www/index.html" do
    content "<h1>Welcome to your new poolparty instance</h1>"
    mode 0644
    owner "www-data"
  end
  
  has_git_repos "paparazzi" do
    :source => "git://github.com/auser/paparazzi.git"
    :at => "/var/www"
  end

end