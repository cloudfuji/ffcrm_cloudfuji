FactoryGirl.define do
  factory :event_rule do
    event {
      %w(customer email app user).sample << "_" <<
      %w(partied danced backflipped moonwalked).sample
    }
    points { rand(100) }
  end
end
