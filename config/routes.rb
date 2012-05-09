begin
  Rails.application.routes.draw do
    cloudfuji_routes
  end
rescue => e
  puts "Error loading the Cloudfuji routes:"
  puts "#{e.inspect}"
end

FatFreeCRM::Application.routes.draw do

  cloudfuji_authentication_routes if Cloudfuji::Platform.on_cloudfuji?

end
