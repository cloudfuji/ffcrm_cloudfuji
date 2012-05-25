require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CloudfujiLeadObserver do

  before do
    @observer = CloudfujiLeadObserver.send :new
  end 
  
  it "should process an event rule when a lead column is updated" do
    user = FactoryGirl.create(:user, :ido_id => "1234")
    @lead = FactoryGirl.create(:lead, :first_name => "Henry", :user => user, :campaign => nil)

    EventRule.create!(
      :event_category  => "lead_attribute_changed", 
      :lead_attribute  => "first_name",
      :action          => "change_lead_score",
      :change_score_by => 5
    )    
    
    EventRule.any_instance.should_receive(:process).with(@lead, ['Henry', 'George'])
    
    @lead.first_name = "George"
    @observer.after_update(@lead)
  end

end