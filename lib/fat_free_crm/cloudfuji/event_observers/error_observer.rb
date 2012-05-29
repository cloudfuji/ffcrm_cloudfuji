module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class ErrorObserver < ::Cloudfuji::EventObserver
        include FatFreeCRM::Cloudfuji::EventObservers::Base
        include ActionView::Helpers::TextHelper

        def error_caught
          email = data['email'] || data['recipient']
          # Look up Lead by ido_id, fall back to email address
          if user_attributes = data['user_attributes']
            lead = Lead.find_by_ido_id(user_attributes['ido_id']) if user_attributes['ido_id'].present?
            lead ||= Lead.find_by_email(user_attributes['email'])
            if lead
              # Set ido_id if blank
              user_attributes

              occurence = ActiveSupport::Inflector.ordinalize(data['occurrences'])
              message = "Error experienced in <strong>#{data['app_name']}</strong> [#{data['environment_name']}] (#{occurence} time): "
              message << "<em>" << truncate(data['message'], :length => 75) << "</em>"
              message << "<br />View the error at: #{data['url']}" if data['url']
              lead.versions.create! :event => message
            end
          end
        end

      end
    end
  end
end
