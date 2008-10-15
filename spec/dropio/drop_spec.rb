require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Drop do
  it "should have the attributes of a Drop" do
    Drop.new.should respond_to(:name, :email, :voicemail, :conference, :fax,
                               :rss, :user_token, :admin_token,
                               :expiration_length, :privacy_type,
                               :delete_permission_type, :max_bytes,
                               :current_bytes, :hidden_upload_url,
                               :upload_url)
  end
  
  it "should find drops by name" do
    mydrop = stub(Drop)
    Client.instance.should_receive(:find_drop).with("mydrop", nil).and_return(mydrop)
    Drop.find("mydrop").should == mydrop
  end

  it "should find drops by name and token" do
    mydrop = stub(Drop)
    Client.instance.should_receive(:find_drop).with("mydrop", "d85a6").and_return(mydrop)
    Drop.find("mydrop", "d85a6").should == mydrop
  end
end