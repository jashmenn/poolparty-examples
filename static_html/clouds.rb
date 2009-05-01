pool :apache_static_site do
  cloud :web do
    #keypair 'id_rsa' # Change this to the name of your keypair if it's not id_rsa
    instances 1
 
    enable :haproxy # Also sets up Apache2
 
    has_file "/var/www/index.htm" do
      content "<h1>Hello world!</h1>"
      owner 'www-data'
      mode 0644
    end
  end
end