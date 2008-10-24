require File.dirname(__FILE__) + '/../spec_helper'

describe Asset do
  before(:each) do
    @asset = Asset.new
    @client = stub(Client)
    Client.stub!(:instance).and_return(@client)
  end
  
  it "should have the attributes of an Asset" do
    @asset.should respond_to(:name, :type, :title, :description, :filesize,
                             :created_at, :thumbnail, :status, :file,
                             :converted, :hidden_url, :pages, :duration,
                             :artist, :track_title, :height, :width,
                             :contents, :url)
  end
  
  it "should have comments" do
    @comment = stub(Comment)
    @client.stub!(:find_comments).with(@asset).and_return([@comment])
    @asset.comments.should == [@comment]
  end
  
  it "should create comments" do
    @comment = stub(Comment)
    @client.should_receive(:create_comment).with(@asset, "Totally rad asset, bro!").and_return(@comment)
    @asset.create_comment("Totally rad asset, bro!").should == @comment
  end
  
  it "should save itself" do
    @client.should_receive(:save_asset).with(@asset)
    @asset.save
  end
  
  it "should destroy itself" do
    @client.should_receive(:destroy_asset).with(@asset)
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
    @client.should_receive(:send_to_fax).with(@asset,"234-567-8901")
    @asset.send_to_fax("234-567-8901")
  end
  
  it "should not fax itself if it's not faxable" do
    @asset.type = "Video"
    @client.should_not_receive(:send_to_fax)
    # TODO: Make this a specific error.
    lambda { @asset.send_to_fax("234-567-8901") }.should raise_error
  end
end
