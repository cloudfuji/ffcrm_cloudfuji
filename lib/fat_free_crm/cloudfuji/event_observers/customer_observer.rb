module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class CustomerObserver < ::Cloudfuji::EventObserver
        # "customer_created"
        # :account_balance => 0
        # :object          => "customer"
        # :email           => "s+cfdemo@cloudfuji.com"
        # :created         => 1332269951
        # :id              => "cus_cpkg4h0KfLD3lp"
        # :livemode        => true
        # :human           => "Customer CREATED (cus_cpkg4h0KfLD3lp), s+cfdemo@cloudfuji.com"}
        def customer_created
          note_customer_activity("#{data['email']} created as a customer with external id #{data['id']}") if data['livemode']
        end

        def customer_signed_up
          note_customer_activity("#{data['first_name']} #{data['last_name']} (#{data['email']}) signed up as a customer")
        end

        private

        def note_customer_activity(message)
          # Be verbose in development environment
          @debug = Rails.env == 'development'

          subject = find_or_create_activity_subject!
          puts "Found subject: #{subject.inspect}" if @debug

          subject.versions.create! :event => message
        end

        def data
          params['data']
        end

        def find_or_create_activity_subject!
          lookups = [Account, Lead, Contact]
          lookups.each do |model|
            puts "#{model}.find_by_email( #{data['email']} )" if @debug
            result = model.find_by_email(data['email'])
            return result if result
          end

          lead = if data['customer_ido_id'].present?
            Lead.find_by_ido_id(data['customer_ido_id'])
          else
            Lead.find_by_email(data['email'])
          end
          lead ||= Lead.new

          lead.email      = data['email']
          lead.ido_id     = data['customer_ido_id']
          lead.first_name = data['first_name'] || data['email'].split("@").first if lead.first_name.blank?
          lead.last_name  = data['last_name']  || data['email'].split("@").last  if lead.last_name.blank?
          lead.user       ||= User.first
          lead.save!

          lead
        end
      end
    end
  end
end
