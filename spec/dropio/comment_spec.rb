require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  before(:each) do
    @comment = Comment.new
    @client = stub(Client)
    Dropio::Resource.stub!(:client).and_return(@client)
    
    @client.stub!(:update_comment).and_return(@comment)
    @client.stub!(:delete_comment).and_return(@comment)
  end
  
  it "should have the attributes of an Comment" do
    @comment.should respond_to(:id, :contents, :created_at)
  end
  
  it "should save itself" do
    @client.should_receive(:update_comment).with(@comment)
    @comment.save
  end
  
  it "should destroy itself" do
    @client.should_receive(:delete_comment).with(@comment)
    @comment.destroy
  end
end
