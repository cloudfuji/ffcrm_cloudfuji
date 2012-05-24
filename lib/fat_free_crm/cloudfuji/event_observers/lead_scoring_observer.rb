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

            EventRule.find_all_by_event(event_name).each do |rule|
              # Find how many times this rule has been applied to this Lead
              count = LeadEventRuleCount.find_by_lead_id_and_event_rule_id(lead, rule) ||
                      LeadEventRuleCount.new(:lead => lead, :event_rule => rule)

              # Don't apply this rule more than once if :once flag is set
              unless rule.once && count.count > 0
                # If :match is present, only apply the rule if data matches string
                if rule.match.blank? || params['data'].inspect.include?(rule.match)
                  lead.without_versioning do
                    lead.update_attribute :score, lead.score + rule.points
                  end
                  # Add history event to lead, to record change of score
                  lead.versions.create! :event => "Rule for '#{event_name}': Score changed by #{rule.points} points. (New total: #{lead.score})"
                  # Increment and save count of rule/lead applications
                  count.count += 1
                  count.save
                end
              end
            end
          end
        end
      end
    end
  end
end
