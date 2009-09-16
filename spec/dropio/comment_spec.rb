require File.dirname(__FILE__) + '/../spec_helper'

describe Dropio::Comment do
  before(:each) do
    @drop = Dropio::Drop.new
    @drop.name = "test_drop"
    @asset = Dropio::Asset.new
    @asset.drop = @drop
    @asset.name = "test_asset"
    @comment = Dropio::Comment.new
    @comment.asset = @asset
    
    @client = Dropio::Client.new
    @api = stub(Dropio::Api)
    @client.service = @api
    
    Dropio::Resource.stub!(:client).and_return(@client)
    Dropio::Resource.client.should == @client
    Dropio::Resource.client.service.should == @api
  end
  
  it "should have the attributes of an Comment" do
    @comment.should respond_to(:id, :contents, :created_at)
  end
  
  it "should save itself" do
    @client.should_receive(:handle).with(:comment,{}).and_return(@comment)
    @api.should_receive(:update_comment).with(@drop.name, @asset.name, @comment.id, "My new content", @drop.default_token).and_return({})
    @comment.contents = "My new content"
    @comment.save
  end
  
  it "should destroy itself" do
    @client.should_receive(:handle).with(:response,{})
    @api.should_receive(:delete_comment).with(@drop.name, @asset.name, @comment.id, @drop.admin_token).and_return({})
    @comment.destroy!
  end
end
