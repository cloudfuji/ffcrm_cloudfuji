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

  describe 'Cloudfuji event received' do
    describe 'Lead scoring' do

      it "should increment a lead's score when an event is fired" do
        user = FactoryGirl.create(:user, :ido_id => "1234")
        @lead = FactoryGirl.create(:lead, :email => 'test_lead@example.com', :user => user, :campaign => nil)

        @rule = FactoryGirl.create :event_rule,
                                   :event_category  => "cloudfuji_event_received",
                                   :cloudfuji_event => "customer_had_tea",
                                   :action          => "change_lead_score",
                                   :change_score_by => 20

        @observer.catch_all
        @lead.reload
        @lead.versions.last.event.should include("Rule for Cloudfuji Event - 'customer_had_tea': Score changed by 20 points")
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
                                   :event_category  => "cloudfuji_event_received",
                                   :cloudfuji_event => "customer_had_tea",
                                   :action          => "change_lead_score",
                                   :change_score_by => 15,
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

      it "should not decrement a lead's score three times if the rule should only be applied twice" do
        user = FactoryGirl.create(:user, :ido_id => "1234")
        @lead = FactoryGirl.create(:lead, :email => 'test_lead@example.com', :user => user, :campaign => nil)

        @rule = FactoryGirl.create :event_rule,
                                   :event_category  => "cloudfuji_event_received",
                                   :cloudfuji_event => "customer_had_tea",
                                   :action          => "change_lead_score",
                                   :change_score_by => -10,
                                   :limit_per_lead  => 1

        test_score = 0
        2.times do |i|
          test_score += -10
          @observer.catch_all
          @lead.reload
          
          @lead.versions.last.event.should == "Rule for Cloudfuji Event - 'customer_had_tea': Score changed by -10 points. (New total: #{test_score})"
          @lead.score.should == test_score
          find_rule_count(@lead, @rule).count.should == i + 1
        end

        # Should only decrement score twice
        @observer.catch_all
        @lead.reload
        @lead.score.should == -20
        find_rule_count(@lead, @rule).count.should == 2
      end
    end
  end
end
