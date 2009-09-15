require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Drop do
  
  before(:each) do
    @client = stub(Client)
    Dropio::Resource.stub!(:client).and_return(@client)
    
    @mydrop = stub(Drop)
    @client.stub!(:drop).and_return(@mydrop)
  end
  
  it "should have the attributes of a Drop" do
    Drop.new.should respond_to(:name, :email, :voicemail, :conference, :fax,
                               :rss, :guest_token, :admin_token,
                               :expiration_length, :guests_can_comment, :guests_can_comment, 
                               :guests_can_delete, :max_bytes,
                               :current_bytes, :hidden_upload_url,
                               :upload_url, :password, :admin_password, :premium_code)
  end
  
  it "should find drops by name" do
    @client.should_receive(:drop).with("mydrop", nil).and_return(@mydrop)
    Drop.find("mydrop").should == @mydrop
  end

  it "should find drops by name and token" do
    @client.should_receive(:drop).with("mydrop", "d85a6").and_return(@mydrop)
    Drop.find("mydrop", "d85a6").should == @mydrop
  end
  
end