pool :apache_static_site do
  cloud :web do
    instances 1
        
    keypair "id_rsa"
    
    using :vmware do
      image_id "/Users/alerner/Documents/vm/Ubuntu32bitVM.vmwarevm/Ubuntu32bitVM.vmx"
      public_ip "192.168.248.133"
    end

    apache

    has_file "/var/www/index.html" do
      content "<h1>Hello world!</h1>"
      owner 'www-data'
      mode 0644
    end
  end
end