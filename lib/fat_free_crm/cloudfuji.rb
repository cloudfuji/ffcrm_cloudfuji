module FatFreeCRM
  module Cloudfuji
    class << self
      def enable_cloudfuji!
        load_observers!
        extend_lead!
				extend_email!
        # Prevent User class from loading if database is empty
        if (User.table_exists? rescue false)
          extend_user!
          setup_authentication!
        end
      end

      def extend_user!
        puts "Extending the User model"
        User.instance_eval do
          include ::Cloudfuji::UserHelper

          validates_presence_of   :ido_id
          validates_uniqueness_of :ido_id

          before_create :make_admin
        end

        User.class_eval do
          def make_admin
            self.admin = true
          end

          def cloudfuji_extra_attributes(extra_attributes)
            self.first_name   = extra_attributes["first_name"]
            self.last_name    = extra_attributes["last_name"]
            self.locale       = extra_attributes["locale"]
            self.email        = extra_attributes["email"]
            self.username   ||= extra_attributes["email"].split("@").first
          end
        end
      end

      def extend_lead!
        puts "Extending the Lead model"
        Lead.instance_eval do
          has_many :lead_event_rule_counts
        end
      end

			def extend_email!
				Email.class_eval do
					# Sent or received
					def direction
						attr_direction = super
						return attr_direction if attr_direction.present? 
						
						# If direction not stored, try to deduce
						# from from/to email addresses.
						if sent_from.include?(user.email)
							'sent'
						elsif sent_to.include?(user.email)
							'received'
						end
					end
				end
			end

      def load_observers!
        require File.expand_path("../cloudfuji/event_observers/base", __FILE__)
        Dir[File.expand_path("../cloudfuji/event_observers/*.rb", __FILE__)].each { |file| require file }
      end

      def setup_authentication!
        Authlogic::Cas.actor_model = User
        Authlogic::Cas.authentication_model = Authentication
        Authlogic::Cas.setup_authentication
      end
    end
  end
end


module ActionDispatch::Routing
  class RouteSet
    Mapper.class_eval do
      def cloudfuji_authentication_routes
        Rails.application.routes.draw do
          scope :module => :authlogic do
            scope :module => :cas do
              match "login"  => "cas_authentication#new_cas_session",     :as => :login
              match "logout" => "cas_authentication#destroy_cas_session", :as => :logout
            end
          end
        end
      end
    end
  end
end


if Cloudfuji::Platform.on_cloudfuji?
  class CloudfujiRailtie < Rails::Railtie
    # Enabling it via this hook means that it'll be reloaded on each
    # request in development mode, so you can make changes in here and
    # it'll be immeidately reflected
    config.to_prepare do
      puts "Enabling Cloudfuji"
      FatFreeCRM::Cloudfuji.enable_cloudfuji!
      puts "Finished enabling Cloudfuji"
    end
  end
end
