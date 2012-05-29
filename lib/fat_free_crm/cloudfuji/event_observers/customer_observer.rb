module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class CustomerObserver < ::Cloudfuji::EventObserver
        include FatFreeCRM::Cloudfuji::EventObservers::Base

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

      end
    end
  end
end
