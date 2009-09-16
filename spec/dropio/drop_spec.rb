require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Drop do
  
  before(:each) do
    @client = Dropio::Client.new
    @api = stub(Dropio::Api)
    @client.service = @api
    
    Dropio::Resource.stub!(:client).and_return(@client)
    Dropio::Resource.client.should == @client
    Dropio::Resource.client.service.should == @api
    
    @mydrop = Dropio::Drop.new
  end
  
  it "should have the attributes of a Drop" do
    Drop.new.should respond_to(:name, :email, :voicemail, :conference, :fax, :rss, :guest_token, :description,
                  :admin_token, :expires_at, :expiration_length, :guests_can_comment, :guests_can_add, :guests_can_delete,
                  :max_bytes, :current_bytes, :hidden_upload_url, :asset_count, :chat_passowrd, :default_view, :upload_url, 
                  :password, :admin_password, :premium_code)
  end
  
  it "should find drops by name" do
    @client.stub!(:drop).and_return(@mydrop)
    @client.should_receive(:drop).with("mydrop", nil).and_return(@mydrop)
    Drop.find("mydrop").should == @mydrop
  end

  it "should find drops by name and token" do
    @client.stub!(:drop).and_return(@mydrop)
    @client.should_receive(:drop).with("mydrop", "d85a6").and_return(@mydrop)
    Drop.find("mydrop", "d85a6").should == @mydrop
  end
  
  it "should have a default token and it should default to the admin" do
    @mydrop.should_receive(:default_token).and_return("tester")
    @mydrop.default_token.should == "tester"
  end
  
  it "should find a set of related assets" do
    @asset = stub(Asset)
    @client.stub!(:assets).with(@mydrop,1).and_return([@asset])
    @mydrop.assets.should == [@asset]
  end
  
  it "should be able to create a new Drop" do
    @client.should_receive(:create_drop).with({:name => "tester"})
    Drop.create({:name => "tester"})
  end
  
  it "should fetch the upload embed code" do
    @client.should_receive(:drop_upload_code).with(@mydrop)
    @mydrop.upload_code
  end
  
  it "should be able to empty itself" do
    @client.should_receive(:empty_drop).with(@mydrop)
    @mydrop.empty
  end
  
  it "should be able to promote a nick" do
    @client.should_receive(:promote_nick).with(@mydrop,"jake")
    @mydrop.promote("jake")
  end
  
  it "should save itself" do
    @client.should_receive(:update_drop).with(@mydrop)
    @mydrop.save
  end
  
  it "should destroy itself" do
    @client.should_receive(:delete_drop).with(@mydrop)
    @mydrop.destroy!
  end
  
  it "should add files from a url" do
    @client.should_receive(:add_file_from_url).with(@mydrop,"http://myurl.com/myfile.txt")
    @mydrop.add_file_from_url("http://myurl.com/myfile.txt")
  end
  
  it "should add files from a path" do
    @client.should_receive(:add_file).with(@mydrop,"/mypath/myfile.txt")
    @mydrop.add_file("/mypath/myfile.txt")
  end
  
  it "should create notes from title and contents" do
    @client.should_receive(:create_note).with(@mydrop,"title","contents")
    @mydrop.create_note("title","contents")
  end
  
  it "should create links from a url, title, and description" do
    @client.should_receive(:create_link).with(@mydrop,"http://drop.io","drop.io","The best!")
    @mydrop.create_link("http://drop.io","drop.io","The best!")
  end
  
  it "should be able to create a twitter subscription" do
    @client.should_receive(:create_twitter_subscription).with(@mydrop,"mytwitter","pass")
    @mydrop.create_twitter_subscription("mytwitter","pass")
  end

  it "should be able to create email subscriptions" do
    @client.should_receive(:create_email_subscription).with(@mydrop,"jake@dropio.com","My welcome message")
    @mydrop.create_email_subscription("jake@dropio.com","My welcome message")
  end
  
  it "should be able to get a list of subscriptions back" do
    @client.should_receive(:subscriptions).with(@mydrop)
    @mydrop.subscriptions
  end
  
  it "should generate a signed url" do
    @client.should_receive(:generate_drop_url).with(@mydrop)    
    @mydrop.generate_url
  end
  
end