# Basic poolparty template

pool :poolparty do
  
  cloud :app do
    instances 2..5
    
    using :metavirt do
      server_config :host => "http://okra", :port => 3000
      using :libvirt do
        image_id "mvi_ef77fdf0"
      end
    end
    
    has_file "/etc/motd", :content => "From metavirt"
    
  end

end