# Basic poolparty template

pool :poolparty do
  
  cloud :app do
    instances 2..5
  end

end