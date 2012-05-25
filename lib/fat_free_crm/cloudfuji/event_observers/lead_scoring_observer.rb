module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class EventRulesObserver < ::Cloudfuji::EventObserver
        # Fire for all events
        def catch_all
          data  = params['data']
          email = data['email'] || data['recipient']
          # Look up Lead by email address
          if lead = Lead.find_by_email(email)
            event_name = "#{params['category']}_#{params['event']}"

            EventRule.find_all_by_event_category_and_cloudfuji_event('cloudfuji_event_received', event_name).each do |rule|
              rule.process(lead, params['data'].inspect)
            end
          end
        end
        
      end
    end
  end
end
