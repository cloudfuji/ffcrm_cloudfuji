module FatFreeCRM
  module Cloudfuji
    module EventObservers
      class LeadScoringObserver < ::Cloudfuji::EventObserver
        # Fire for all events
        def catch_all
          # Look up Lead by email
          if lead = Lead.find_by_email(params['data']['email'])
            LeadScoringRule.find_all_by_event(params['event']).each do |rule|
              # Find how many times this rule has been applied to this Lead
              count = LeadScoringRuleCount.find_by_lead_id_and_lead_scoring_rule_id(lead, rule) ||
                      LeadScoringRuleCount.new(:lead => lead, :lead_scoring_rule => rule)

              # Don't apply this rule again if it should only be applied once
              unless rule.once && count.count > 0
                lead.update_attribute :score, lead.score + rule.points
                # Add history event to lead to display score change
                lead.versions.create! :event => "Score changed by #{rule.points} points, new score: #{lead.score}"
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
