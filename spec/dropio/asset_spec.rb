require File.dirname(__FILE__) + '/../spec_helper'

describe Dropio::Asset do
  before(:each) do
    @drop = Dropio::Drop.new
    @drop.name = "test_drop"
    @asset = Dropio::Asset.new
    @asset.name = "test_asset"
    @asset.drop = @drop
    
    @client = Dropio::Client.new
    @api = stub(Dropio::Api)
    @client.service = @api
    
    Dropio::Resource.stub!(:client).and_return(@client)
    Dropio::Resource.client.should == @client
    Dropio::Resource.client.service.should == @api
  end
  
  it "should have the attributes of an Asset" do
    @asset.should respond_to(:drop, :name, :type, :title, :description, :filesize, :created_at,
                  :thumbnail, :status, :file, :converted, :hidden_url, :pages, :fax_status,
                  :duration, :artist, :track_title, :height, :width, :contents, :url)
  end
  
  it "should have comments" do
    @comment = stub(Comment)
    @client.should_receive(:handle).with(:comments,{}).and_return([@comment])
    @api.stub!(:comments).with(@drop.name, @asset.name, @drop.default_token).and_return({})
    @asset.comments.should == [@comment]
  end
  
  it "should create comments" do
    @comment = stub(Comment)
    @client.should_receive(:handle).with(:comment,{}).and_return(@comment)
    @api.stub!(:create_comment).with(@drop.name, @asset.name, "Totally rad asset, bro!",@drop.default_token).and_return({})
    @asset.create_comment("Totally rad asset, bro!").should == @comment
  end
  
  it "should save itself" do
    @client.should_receive(:handle).with(:asset,{})
    expected_hash = {:url=> "http://drop.io", :contents=>nil, :description=>nil, :title=>nil}
    @asset.url = expected_hash[:url]
    @api.stub!(:update_asset).with(@drop.name, @asset.name, expected_hash,@drop.default_token).and_return({})
    @asset.save
  end
  
  it "should destroy itself" do
    @client.should_receive(:handle).with(:response,{})
    @api.stub!(:delete_asset).with(@drop.name, @asset.name,@drop.default_token).and_return({})
    @asset.destroy!
  end
  
  it "should be faxable if and only if it's a document" do
    @asset.type = "Document"
    @asset.should be_faxable
    @asset.type = "Video"
    @asset.should_not be_faxable
  end
  
  it "should fax itself to a phone number" do
    @asset.type = "Document"
    
    @client.should_receive(:handle).with(:response,{})
    @api.stub!(:send_asset_to_fax).with(@drop.name, @asset.name,"234-567-8901",@drop.default_token).and_return({})
    @asset.send_to_fax("234-567-8901")
  end
  
  it "should email itself to a comma separated list of emails with an optional message" do
    @asset.type = "Document"
    @client.should_receive(:handle).with(:response,{})
    @api.stub!(:send_asset_to_emails).with(@drop.name, @asset.name,"jake@dropio.com, jacob@dropio.com", "Awesome stuff!", @drop.default_token).and_return({})
    @asset.send_to_emails("jake@dropio.com, jacob@dropio.com","Awesome stuff!")
    
    @client.should_receive(:handle).with(:response,{})
    @api.stub!(:send_asset_to_emails).with(@drop.name, @asset.name,"jake@dropio.com, jacob@dropio.com", nil, @drop.default_token).and_return({})
    @asset.send_to_emails("jake@dropio.com, jacob@dropio.com")
  end
  
  it "should send itself to another drop." do
    @target_drop = Drop.new
    @target_drop.name = "target_drop"
    @target_drop.guest_token = "guest_token"
    @client.should_receive(:handle).with(:response,{})
    @api.stub!(:send_asset_to_drop).with(@drop.name, @asset.name, @target_drop.name, @target_drop.guest_token, @drop.default_token).and_return({})
    @asset.send_to_drop(@target_drop)
  end
  
  it "should copy itself to another drop." do
    @target_drop = Drop.new
    @target_drop.name = "target_drop"
    @target_drop.guest_token = "guest_token"
    @client.should_receive(:handle).with(:response,{})
    @api.stub!(:copy_asset).with(@drop.name, @asset.name, @target_drop.name, @target_drop.guest_token, @drop.default_token).and_return({})
    @asset.copy_to(@target_drop)
  end
  
  it "should move itself to another drop." do
    @target_drop = Drop.new
    @target_drop.name = "target_drop"
    @target_drop.guest_token = "guest_token"
    @client.should_receive(:handle).with(:response,{})
    @api.stub!(:move_asset).with(@drop.name, @asset.name, @target_drop.name, @target_drop.guest_token, @drop.default_token).and_return({})
    @asset.move_to(@target_drop)
  end
  
  it "should not fax itself if it's not faxable" do
    @asset.type = "Video"
    @api.should_not_receive(:send_asset_to_fax)
    # TODO: Make this a specific error.
    lambda { @asset.send_to_fax("234-567-8901") }.should raise_error
  end
  
  it "should find itself" do
    @client.should_receive(:handle).with(:asset,{}).and_return(@asset)
    @api.should_receive(:asset).with(@drop.name, @asset.name, @drop.default_token).and_return({})
    Asset.find(@drop,@asset.name).should == @asset
  end
  
  it "should generate a signed url" do
    @api.should_receive(:generate_drop_url).with(@drop.name,@asset.name,@drop.default_token)  
    @asset.generate_url
  end
  
  it "should get it's embed_code" do
    @client.should_receive(:handle).with(:response,{})
    @api.should_receive(:asset_embed_code).with(@drop.name,@asset.name,@drop.default_token).and_return({})
    @asset.embed_code
  end
  
end