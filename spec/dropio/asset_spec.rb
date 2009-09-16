require File.dirname(__FILE__) + '/../spec_helper'

describe Dropio::Asset do
  before(:each) do
    @drop = Dropio::Drop.new
    @asset = Dropio::Asset.new
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
    @comment = stub(Dropio::Comment)
    @client.stub!(:comments).with(@asset).and_return([@comment])
    @asset.comments.should == [@comment]
  end
  
  it "should create comments" do
    @comment = stub(Dropio::Comment)
    @client.should_receive(:create_comment).with(@asset, "Totally rad asset, bro!").and_return(@comment)
    @asset.create_comment("Totally rad asset, bro!").should == @comment
  end
  
  it "should save itself" do
    @client.should_receive(:update_asset).with(@asset)
    @asset.save
  end
  
  it "should destroy itself" do
    @client.should_receive(:delete_asset).with(@asset)
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
    @client.should_receive(:send_asset_to_fax).with(@asset,"234-567-8901")
    @asset.send_to_fax("234-567-8901")
  end
  
  it "should email itself to a comma separated list of emails with an optional message" do
    @asset.type = "Document"
    @client.should_receive(:send_asset_to_emails).with(@asset,"jake@dropio.com, jacob@dropio.com", "Awesome stuff!")
    @asset.send_to_emails("jake@dropio.com, jacob@dropio.com","Awesome stuff!")
    
    @client.should_receive(:send_asset_to_emails).with(@asset,"jake@dropio.com, jacob@dropio.com", nil)
    @asset.send_to_emails("jake@dropio.com, jacob@dropio.com")
  end
  
  it "should send itself to another drop." do
    @client.should_receive(:send_asset_to_drop).with(@asset,@asset.drop)
    @asset.send_to_drop(@asset.drop)
  end
  
  it "should copy itself to another drop." do
    @client.should_receive(:copy_asset).with(@asset,@asset.drop)
    @asset.copy_to(@asset.drop)
  end
  
  it "should move itself to another drop." do
    @client.should_receive(:move_asset).with(@asset,@asset.drop)
    @asset.move_to(@asset.drop)
  end
  
  it "should not fax itself if it's not faxable" do
    @asset.type = "Video"
    @client.should_not_receive(:send_asset_to_fax)
    # TODO: Make this a specific error.
    lambda { @asset.send_to_fax("234-567-8901") }.should raise_error
  end
  
  it "should find itself" do
    @client.stub!(:asset).and_return(@asset)
    @client.should_receive(:asset).with(@asset.drop,@asset.name)
    Asset.find(@drop,@asset.name).should == @asset
  end
  
  it "should generate a signed url" do
    @client.should_receive(:generate_asset_url).with(@asset)    
    @asset.generate_url
  end
  
  it "should get it's embed_code" do
    @client.should_receive(:asset_embed_code).with(@asset)
    @asset.embed_code
  end
  
end