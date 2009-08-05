# Basic poolparty template

pool :poolparty do
  
  cloud :app do
    instances 2..5
    
    keypair "id_rsa"
    
    using :vmware do
      image_id "/Users/alerner/Documents/vm/Ubuntu32bitVM.vmwarevm/Ubuntu32bitVM.vmx"
      public_ip "192.168.248.133"
    end
    
    has_file "/etc/motd", :content => "From metavirt"
    
  end

end