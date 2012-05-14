module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class AppObserver < ::Cloudfuji::EventObserver
        def app_claimed
          # Be verbose in development environment
          debug = Rails.env == 'development'

          data = params['data']
          ido_id = data.try(:[], 'ido_id')

          if user = User.find(:first, :conditions => ["email = ? OR ido_id = ?", data['email'], data['ido_id']])
            puts "Updating #{user.inspect} with incoming data #{params.inspect}" if debug
          else
            user = User.new
            puts "Creating User with incoming data #{params.inspect}" if debug
          end

          puts "Authlogic username column: #{::Authlogic::Cas.cas_username_column}=" if debug
          puts "Setting username to: #{ido_id}" if debug

          user.email      = data['email']
          # Set first and last name from email if both blank
          if user.first_name.blank? && user.last_name.blank?
            user.first_name = user.email.split('@').first
            user.last_name  = user.email.split('@').last
          end
          user.username   = ido_id
          user.deleted_at = nil
          user.admin = true
          user.send("#{::Authlogic::Cas.cas_username_column}=".to_sym, ido_id)

          puts user.inspect if debug
          user.save!
        end
      end
    end
  end
end
