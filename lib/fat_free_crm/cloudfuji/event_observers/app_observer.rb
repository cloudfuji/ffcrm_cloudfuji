module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class AppObserver < ::Cloudfuji::EventObserver
        def app_claimed
          if user = User.find_by_email(data['email'])
            puts "Updating #{User.first.inspect} with incoming data #{params.inspect}"
          else
            user = User.new
            puts "Creating User with incoming data #{params.inspect}"
          end

          puts "Authlogic username column: #{::Authlogic::Cas.cas_username_column}="
          puts "Setting username to: #{params.try(:[], 'ido_id')}"

          data = params['data']
          user.email      = data['email']
          user.first_name = user.email.split('@').first
          user.last_name  = user.email.split('@').last
          user.username   = data['email']
          user.deleted_at = nil
          user.admin = true
          user.send("#{::Authlogic::Cas.cas_username_column}=".to_sym, data.try(:[], 'ido_id'))
          puts user.inspect
          user.save!
        end
      end
    end
  end
end
