require File.dirname(__FILE__) + '/spec_helper.rb'

describe Dropio do
  it "should store the API key" do
    Dropio::Config.api_key = "83a05513ddddb73e75c9d8146c115f7fd8e90de6"
    Dropio::Config.api_key.should == "83a05513ddddb73e75c9d8146c115f7fd8e90de6"
  end
end