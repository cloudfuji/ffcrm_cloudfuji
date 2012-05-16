require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include FatFreeCRM::Cloudfuji::EventObservers

describe LeadScoringObserver do
  before do
    @observer = LeadScoringObserver.new
    @observer.params = {
      'event' => 'customer_had_tea',
      "data" => {
        "email" => "test_lead@example.com",
        "human" => "Customer drank some tea (jasmine), test_lead@example.com"
      }
    }
  end

  def find_rule_count(lead, rule)
    LeadScoringRuleCount.find_by_lead_id_and_lead_scoring_rule_id(lead, rule)
  end

  it "should increment a lead's score when an event is fired" do
    user = FactoryGirl.create(:user, :ido_id => "1234")
    @lead = FactoryGirl.create(:lead, :email => 'test_lead@example.com', :user => user, :campaign => nil)

    @rule = FactoryGirl.create :lead_scoring_rule,
                               :event  => "customer_had_tea",
                               :points => 20

    @observer.catch_all
    @lead.reload
    @lead.versions.last.event.should include("Score changed by 20 points")
    @lead.score.should == 20
    find_rule_count(@lead, @rule).count.should == 1

    # Should increment score twice
    @observer.catch_all
    @lead.reload
    @lead.score.should == 40
    find_rule_count(@lead, @rule).count.should == 2
  end

  it "should not decrement a lead's score twice if the rule should only be applied once" do
    user = FactoryGirl.create(:user, :ido_id => "1234")
    @lead = FactoryGirl.create(:lead, :email => 'test_lead@example.com', :user => user, :campaign => nil)

    @rule = FactoryGirl.create :lead_scoring_rule,
                               :event  => "customer_had_tea",
                               :points => -10,
                               :once => true

    @observer.catch_all
    @lead.reload
    @lead.versions.last.event.should include("Score changed by -10 points")
    @lead.score.should == -10
    find_rule_count(@lead, @rule).count.should == 1

    # Should only increment score once
    @observer.catch_all
    @lead.reload
    @lead.score.should == -10
    find_rule_count(@lead, @rule).count.should == 1
  end
end
