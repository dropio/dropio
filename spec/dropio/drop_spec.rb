require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Drop do
  
  before(:each) do
    @client = Dropio::Client.new
    @api = stub(Dropio::Api)
    @client.service = @api
    
    Dropio::Resource.stub!(:client).and_return(@client)
    Dropio::Resource.client.should == @client
    Dropio::Resource.client.service.should == @api
    
    @mydrop = Dropio::Drop.new(:name => "test_drop",:admin_token => "admin_token")
  end
  
  it "should have the attributes of a Drop" do
    Drop.new.should respond_to(:name, :email, :voicemail, :conference, :fax, :rss, :guest_token, :description,
                  :admin_token, :expires_at, :expiration_length, :guests_can_comment, :guests_can_add, :guests_can_delete,
                  :max_bytes, :current_bytes, :hidden_upload_url, :asset_count, :chat_password, :default_view, 
                  :password, :admin_password, :premium_code, :admin_email, :email_key)
  end
  
  it "should find drops by name" do
    @client.should_receive(:handle).with(:drop,{}).and_return(@mydrop)
    @api.should_receive(:drop).with("mydrop", nil).and_return({})
    Drop.find("mydrop").should == @mydrop
  end

  it "should find drops by name and token" do
    @client.should_receive(:handle).with(:drop,{}).and_return(@mydrop)
    @api.should_receive(:drop).with("mydrop", "d85a6").and_return({})
    Drop.find("mydrop", "d85a6").should == @mydrop
  end
  
  it "should have a default token and it should default to the admin" do
    @mydrop.admin_token = "tester"
    @mydrop.default_token.should == "tester"
  end
  
  it "should find a set of related assets" do
    @asset = stub(Asset)
    @client.should_receive(:handle).with(:assets,{}).and_return([@asset])
    @api.stub!(:assets).with(@mydrop.name,1,:oldest,@mydrop.default_token).and_return({})
    @mydrop.assets.should == [@asset]
  end
  
  it "should be able to create a new Drop" do
    @client.should_receive(:handle).with(:drop,{}).and_return(@mydrop)
    @api.should_receive(:create_drop).with({:name => "tester"}).and_return({})
    Drop.create({:name => "tester"}).should == @mydrop
  end
  
  it "should fetch the upload embed code" do
    @client.should_receive(:handle).with(:response,{})
    @api.should_receive(:drop_upload_code).with(@mydrop.name,@mydrop.default_token).and_return({})
    @mydrop.upload_code
  end
  
  it "should be able to empty itself" do
    @client.should_receive(:handle).with(:response,{}).and_return({})
    @api.should_receive(:empty_drop).with(@mydrop.name,@mydrop.admin_token).and_return({})
    @mydrop.empty
  end
  
  it "should be able to promote a nick" do
    @client.should_receive(:handle).with(:response,{})
    @api.should_receive(:promote_nick).with(@mydrop.name,"jake",@mydrop.admin_token).and_return({})
    @mydrop.promote("jake")
  end
  
  it "should save itself" do
    @client.should_receive(:handle).with(:drop,{}).and_return(@mydrop)
    expected_hash = {:password=>"test_password", :expiration_length=>nil, :admin_password=>nil, :guests_can_comment=>nil, 
                     :premium_code=>nil, :guests_can_add=>nil, :chat_password=>nil, :guests_can_delete=>nil, 
                     :admin_email=>nil, :default_view=>nil, :email_key=>nil, :description=>nil}
    @api.should_receive(:update_drop).with(@mydrop.name,@mydrop.admin_token,expected_hash).and_return({})
    @mydrop.password = "test_password"
    @mydrop.save
  end
  
  it "should destroy itself" do
    @client.should_receive(:handle).with(:response,{})
    @api.should_receive(:delete_drop).with(@mydrop.name,@mydrop.admin_token).and_return({})
    @mydrop.destroy!
  end
  
  it "should add files from a url" do
    @asset = stub(Asset)
    @client.should_receive(:handle).with(:asset,{}).and_return(@asset)
    @api.should_receive(:add_file_from_url).with(@mydrop.name,"http://myurl.com/myfile.txt",@mydrop.default_token).and_return({})
    @mydrop.add_file_from_url("http://myurl.com/myfile.txt").should == @asset
  end
  
  it "should add files from a path" do
    @asset = stub(Asset)
    @client.should_receive(:handle).with(:asset,{}).and_return(@asset)
    @api.should_receive(:add_file).with(@mydrop.name,"/mypath/myfile.txt",@mydrop.default_token, nil).and_return({})
    @mydrop.add_file("/mypath/myfile.txt").should == @asset
  end
  
  it "should create notes from title and contents" do
    @asset = stub(Asset)
    @client.should_receive(:handle).with(:asset,{}).and_return(@asset)
    @api.should_receive(:create_note).with(@mydrop.name,"contents", "title",@mydrop.default_token).and_return({})
    @mydrop.create_note("contents","title").should == @asset
  end
  
  it "should create links from a url, title, and description" do
    @asset = stub(Asset)
    @client.should_receive(:handle).with(:asset,{}).and_return(@asset)
    @api.should_receive(:create_link).with(@mydrop.name,"http://drop.io","drop.io","The best!",@mydrop.default_token).and_return({})
    @mydrop.create_link("http://drop.io","drop.io","The best!").should == @asset
  end
  
  it "should be able to create a twitter subscription" do
    @sub = stub(Subscription)
    @client.should_receive(:handle).with(:subscription,{}).and_return(@sub)
    @api.should_receive(:create_twitter_subscription).with(@mydrop.name,"mytwitter","pass",nil,{},@mydrop.default_token).and_return({})
    @mydrop.create_twitter_subscription("mytwitter","pass")
  end

  it "should be able to create email subscriptions" do
    @sub = stub(Subscription)
    @client.should_receive(:handle).with(:subscription,{}).and_return(@sub)
    @api.should_receive(:create_email_subscription).with(@mydrop.name,"jake@dropio.com","My welcome message",nil,nil,nil,{},@mydrop.default_token).and_return({})
    @mydrop.create_email_subscription("jake@dropio.com","My welcome message")
  end
  
  it "should be able to get a list of subscriptions back" do
    @sub = stub(Subscription)
    @client.should_receive(:handle).with(:subscriptions,{}).and_return([@sub])
    @api.stub!(:subscriptions).with(@mydrop.name, @mydrop.admin_token).and_return({})
    @mydrop.subscriptions.should == [@sub]
  end
  
  it "should generate a signed url" do
    @api.should_receive(:generate_drop_url).with(@mydrop.name,@mydrop.default_token)    
    @mydrop.generate_url
  end
  
end