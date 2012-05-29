module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class EventRulesObserver < ::Cloudfuji::EventObserver
        include FatFreeCRM::Cloudfuji::EventObservers::Base

        # Fire for all events
        def catch_all
          if lead = find_lead_by_data
            event_name = "#{params['category']}_#{params['event']}"
            EventRule.find_all_by_event_category_and_cloudfuji_event('cloudfuji_event_received', event_name).each do |rule|
              rule.process(lead, params['data'])
            end
          end
        end

      end
    end
  end
end
