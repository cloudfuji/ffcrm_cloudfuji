Rails.application.routes.draw do
  begin
    cloudfuji_routes

    if Cloudfuji::Platform.on_cloudfuji?
      # Remove existing authentication routes
      r = Rails.application.routes
      r.set.routes.reject! {|r| %w(login logout).include? r.name }
      r.set.send "clear_cache!"
      # Setup cloudfuji authentication routes
      cloudfuji_authentication_routes
    end
  rescue => e
    puts "Error loading the Cloudfuji routes:"
    puts "#{e.inspect}"
  end

  namespace :admin do
    resources :event_rules, :only => :index do
      post :update, :on => :collection
    end
  end

  resources :unknown_emails, :only => :index do
    member do
      delete :ignore
      put    :convert
    end
  end
end
