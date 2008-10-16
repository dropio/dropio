require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  before(:each) do
    @comment = Comment.new
    @client = stub(Client)
    Client.stub!(:instance).and_return(@client)
  end
  
  it "should have the attributes of an Comment" do
    @comment.should respond_to(:id, :contents, :created_at)
  end
  
  it "should save itself" do
    @client.should_receive(:save_comment).with(@comment)
    @comment.save
  end
  
  it "should destroy itself" do
    @client.should_receive(:destroy_comment).with(@comment)
    @comment.destroy
  end
end
