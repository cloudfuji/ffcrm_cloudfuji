module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class EventRulesObserver < ::Cloudfuji::EventObserver
        include FatFreeCRM::Cloudfuji::EventObservers::Base

        # Fire for all events
        def catch_all
          if lead = find_lead_by_data
            event_name = "#{params['category']}_#{params['event']}"
            EventRule.find(:all, :conditions => ["event_category IN ('cloudfuji_event_received', 'page_loaded') AND cloudfuji_event = ?", event_name]).each do |rule|
              rule.process(lead, params)
            end
          end
        end

      end
    end
  end
end
