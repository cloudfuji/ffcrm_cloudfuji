require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventRule do
  describe "validations" do

    it "should create a new instance given valid attributes" do
      EventRule.create!(
        :event_category  => "cloudfuji_event_received", 
        :cloudfuji_event => "dummy_event",
        :action          => "add_tag",
        :tag      => "EventTag"
      )
    end
      
    it "should be invalid without a cloudfuji_event if event category is cloudfuji_event_received" do
      @event_rule = EventRule.new :event_category  => "cloudfuji_event_received"
      @event_rule.should_not be_valid
      @event_rule.errors[:cloudfuji_event].should include("can't be blank")
    end
    
    it "should be invalid without a lead_attribute if event category is lead_attribute_changed" do
      @event_rule = EventRule.new :event_category  => "lead_attribute_changed"
      @event_rule.should_not be_valid
      @event_rule.errors[:lead_attribute].should include("can't be blank")
    end
    
    it "should be invalid without a tag if action is add_tag or remove_tag" do
      @event_rule = EventRule.new :action  => "add_tag"
      @event_rule.should_not be_valid
      @event_rule.errors[:tag].should include("can't be blank")
      @event_rule.action = "remove_tag"
      @event_rule.should_not be_valid
      @event_rule.errors[:tag].should include("can't be blank")
    end    
    
    it "should be invalid without change_score_by if action is change_lead_score" do
      @event_rule = EventRule.new :event_category => "cloudfuji_event_received",
                                  :cloudfuji_event => "dummy_event",
                                  :action => "change_lead_score",
                                  :change_score_by => nil
      @event_rule.should_not be_valid

      @event_rule.errors[:change_score_by].should include("is not a number")
    end    
    
  end
end