module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class LeadScoringObserver < ::Cloudfuji::EventObserver
        # Fire for all events
        def catch_all
          data  = params['data']
          email = data['email'] || data['recipient']
          # Look up Lead by email address
          if lead = Lead.find_by_email(email)
            event_name = "#{params['category']}_#{params['event']}"

            LeadScoringRule.find_all_by_event(event_name).each do |rule|
              # Find how many times this rule has been applied to this Lead
              count = LeadScoringRuleCount.find_by_lead_id_and_lead_scoring_rule_id(lead, rule) ||
                      LeadScoringRuleCount.new(:lead => lead, :lead_scoring_rule => rule)

              # Don't apply this rule more than once if :once flag is set
              unless rule.once && count.count > 0
                # If :match is present, only apply the rule if data matches string
                if rule.match.blank? || params['data'].inspect.include?(rule.match)
                  lead.update_attribute :score, lead.score + rule.points
                  # Add history event to lead, to record change of score
                  lead.versions.create! :event => "Event '#{event_name}' - Score changed by #{rule.points} points, new score: #{lead.score}"
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
