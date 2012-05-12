require 'spec_helper'

include FatFreeCRM::Cloudfuji::EventObservers

describe AppObserver do
  before do

  end

  describe "App Claimed" do
    it "should update a known user if app is claimed by a recognized email address" do
    end

    it "should create a new user if app is claimed by an unrecognized email address" do
    end

  end

end
