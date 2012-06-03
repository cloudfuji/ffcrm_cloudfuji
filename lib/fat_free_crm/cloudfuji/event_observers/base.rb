module FatFreeCRM
  module Cloudfuji
    module EventObservers
      module Base
        # Shared methods for observers

        def find_lead_by_data
          # Look up Lead by ido_id or email address.
          lead = Lead.find_by_ido_id(data['customer_ido_id']) if data['customer_ido_id'].present?
          lead ||= Lead.find_by_email(email)
          update_ido_id_if_blank(lead)
          lead
        end


        def find_or_create_activity_subject!
          models = [Lead, Contact, Account]
          models.each do |model|
            has_ido_id = model.new.respond_to?(:ido_id)

            if data['customer_ido_id'].present? && has_ido_id
              asset = model.find_by_ido_id(data['customer_ido_id'])
              return asset if asset
            end

            if asset = model.find_by_email(email)
              update_ido_id_if_blank(asset) if has_ido_id
              return asset if asset
            end
          end

          puts "No pre-existing records found, creating a lead"
          lead = Lead.new(
                  :email      => email,
                  :ido_id     => data['customer_ido_id'],
                  :first_name => email.split("@").first,
                  :last_name  => email.split("@").last,
                  :user       => User.first)

          lead.first_name = data['first_name'] if data['first_name'].present?
          lead.last_name  = data['last_name']  if data['last_name'].present?
          
          lead.save!
          
          lead
        end


        private

        def update_ido_id_if_blank(asset)
          # If lead was found by email and has blank ido_id,
          # but customer_ido_id is present, then update ido_id
          if asset && asset.respond_to?(:ido_id) &&
             asset.ido_id.blank? && data['customer_ido_id'].present?
            asset.update_attribute :ido_id, data['customer_ido_id']
          end
        end

        def data
          params['data']
        end

        def email
          data['email'] || data['recipient']
        end

      end
    end
  end
end
