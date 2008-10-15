require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  it "should have the attributes of an Comment" do
    Comment.new.should respond_to(:id, :contents, :created_at)
  end
end
