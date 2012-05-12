# Remove existing authentication routes
r = Rails.application.routes
r.set.routes.reject! {|r| %w(login logout).include? r.name }
r.set.send "clear_cache!"

begin
  Rails.application.routes.draw do
    cloudfuji_routes
    cloudfuji_authentication_routes if Cloudfuji::Platform.on_cloudfuji?
  end
rescue => e
  puts "Error loading the Cloudfuji routes:"
  puts "#{e.inspect}"
end
