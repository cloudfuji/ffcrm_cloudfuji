require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include FatFreeCRM::Cloudfuji::EventObservers

describe CustomerObserver do
  describe "Customer activity" do
    before do
      @observer = CustomerObserver.new
      @observer.params = {
        "data" => {
          "object" => "customer",
          "account_balance" => 0,
          "email" => "test_lead@example.com",
          "id" => "cus_8Ezl23ASXmAb7Y",
          "created" => 1336871750,
          "livemode" => true,
          "human" => "Customer CREATED (cus_8Ezl23ASXmAb7Y), test_lead@example.com"
        }
      }
    end

    it "should update a known lead when known customer is created" do
      user = FactoryGirl.create(:user, :ido_id => "1234")
      @lead = FactoryGirl.create(:lead, :email => 'test_lead@example.com', :user => user, :campaign => nil)

      @observer.customer_created

      # Should not create a new lead
      Lead.find_all_by_email('test_lead@example.com').size.should == 1

      @lead.reload
      @lead.versions.last.event.should include("test_lead@example.com created as a customer")
    end

    it "should create a new lead when unknown customer is created" do
      @observer.customer_created

      @lead = Lead.find_by_email('test_lead@example.com')
      @lead.first_name.should == "test_lead"
      @lead.last_name.should == "example.com"
      @lead.versions.last.event.should include("test_lead@example.com created as a customer")
    end
  end
end
