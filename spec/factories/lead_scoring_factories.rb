FactoryGirl.define do
  factory :event_rule do
    event_category { %w(cloudfuji_event_received lead_attribute_changed).sample }

    cloudfuji_event {
      %w(customer email app user).sample << "_" <<
      %w(partied danced backflipped moonwalked).sample
    }
    lead_attribute {  %w(username score first_name last_name).sample }
    
    action { %w(add_tag remove_tag change_lead_score send_notification).sample }
    action_tag { 'EventTag' }
    change_score_by { rand(100) }
  end
end
