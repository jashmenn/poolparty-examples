pool(:hadoop_cluster) do
  cloud(:hadoop) do
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

    verify do
      ping
    end

    hadoop


  end # cloud :hadoop
end # pool

# vim: ft=ruby
