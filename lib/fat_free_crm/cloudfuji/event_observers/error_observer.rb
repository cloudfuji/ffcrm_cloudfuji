module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class ErrorObserver < ::Cloudfuji::EventObserver

        def error_caught
          email = data['email'] || data['recipient']
          # Look up Lead by ido_id, fall back to email address
          if user_attributes = data['user_attributes']
            lead = Lead.find_by_ido_id(user_attributes['ido_id']) if user_attributes['ido_id'].present?
            lead ||= Lead.find_by_email(user_attributes['email'])
            if lead
              occurence = ActiveSupport::Inflector.ordinalize(data['occurrences'])
              message = "Error occurred for the #{occurence} time in #{data['app_name']} [#{data['environment_name']}]"
              message << " - View the error at: #{data['url']}" if data['url']
              lead.versions.create! :event => message
            end
          end
        end

        private

        def data
          params['data']
        end

      end
    end
  end
end
