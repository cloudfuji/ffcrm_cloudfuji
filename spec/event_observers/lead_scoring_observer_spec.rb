require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include FatFreeCRM::Cloudfuji::EventObservers

describe EventRulesObserver do
  before do
    @observer = EventRulesObserver.new
    @observer.params = {
      'category' => 'customer',
      'event'    => 'had_tea',
      "data" => {
        "email" => "test_lead@example.com",
        "type_of_tea" => "Jasmine"
      }
    }
  end

  def find_rule_count(lead, rule)
    LeadEventRuleCount.find_by_lead_id_and_event_rule_id(lead, rule)
  end

  it "should increment a lead's score when an event is fired" do
    user = FactoryGirl.create(:user, :ido_id => "1234")
    @lead = FactoryGirl.create(:lead, :email => 'test_lead@example.com', :user => user, :campaign => nil)

    @rule = FactoryGirl.create :event_rule,
                               :event  => "customer_had_tea",
                               :points => 20

    @observer.catch_all
    @lead.reload
    @lead.versions.last.event.should include("Rule for 'customer_had_tea': Score changed by 20 points")
    @lead.score.should == 20
    find_rule_count(@lead, @rule).count.should == 1

    # Should increment score twice
    @observer.catch_all
    @lead.reload
    @lead.score.should == 40
    find_rule_count(@lead, @rule).count.should == 2
  end

  it "should increment a lead's score only when matching data is present" do
    user = FactoryGirl.create(:user, :ido_id => "1234")
    @lead = FactoryGirl.create(:lead, :email => 'test_lead@example.com', :user => user, :campaign => nil)

    @rule = FactoryGirl.create :event_rule,
                               :event  => "customer_had_tea",
                               :points => 15,
                               :match  => "Russian Earl Grey"

    @observer.catch_all
    @lead.reload
    @lead.score.should == 0
    # No LeadEventRuleCount should be created yet
    find_rule_count(@lead, @rule).should == nil

    @observer.params['data']['type_of_tea'] = "Russian Earl Grey"
    @observer.catch_all

    @lead.reload
    @lead.score.should == 15
    find_rule_count(@lead, @rule).count.should == 1
  end

  it "should not decrement a lead's score twice if the rule should only be applied once" do
    user = FactoryGirl.create(:user, :ido_id => "1234")
    @lead = FactoryGirl.create(:lead, :email => 'test_lead@example.com', :user => user, :campaign => nil)

    @rule = FactoryGirl.create :event_rule,
                               :event  => "customer_had_tea",
                               :points => -10,
                               :once => true

    @observer.catch_all
    @lead.reload
    @lead.versions.last.event.should include("Rule for 'customer_had_tea': Score changed by -10 points")
    @lead.score.should == -10
    find_rule_count(@lead, @rule).count.should == 1

    # Should only increment score once
    @observer.catch_all
    @lead.reload
    @lead.score.should == -10
    find_rule_count(@lead, @rule).count.should == 1
  end
end
