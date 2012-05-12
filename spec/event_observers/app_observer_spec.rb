require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include FatFreeCRM::Cloudfuji::EventObservers

describe AppObserver do
  describe "App Claimed" do
    before do
      @observer = AppObserver.new
      @observer.params = {
        'data' => {
          'ido_id' => '57a57c56b57d76e76f',
          'email'  => 'cloudfuji_user@cloudfuji.com'
        }
      }
    end

    it "should update a known user if app is claimed by a recognized email address" do
      @user = FactoryGirl.create(:user, :email => 'cloudfuji_user@cloudfuji.com', :ido_id => "123456789")
      original_name = [@user.first_name, @user.last_name]

      @observer.app_claimed

      # Should not create a new user
      User.find_all_by_email('cloudfuji_user@cloudfuji.com').size.should == 1

      @user.reload
      [@user.first_name, @user.last_name].should == original_name
      @user.ido_id.should == '57a57c56b57d76e76f'
    end

    it "should create a new user if app is claimed by an unrecognized email address" do
      @observer.app_claimed

      @user = User.find_by_email('cloudfuji_user@cloudfuji.com')
      @user.first_name.should == "cloudfuji_user"
      @user.last_name.should == "cloudfuji.com"
    end
  end
end
