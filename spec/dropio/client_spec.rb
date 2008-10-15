require File.dirname(__FILE__) + '/../spec_helper'

describe Client do
  it "should find drops" do
    Dropio.api_url = "http://api.drop.io"
    Dropio.api_key = "43myapikey13"
    
    api_response_body = stub("API Response Body")
    api_response      = stub("API Response", :body => api_response_body)
    mydrop            = stub(Drop)
    
    Net::HTTP.should_receive(:get_response).
              with(URI("http://api.drop.io/drops/mydrop?api_key=43myapikey13&token=93mydroptoken97&format=json")).
              and_return(api_response)
    Client::Mapper.should_receive(:map_drops).with(api_response_body).and_return(mydrop)
    
    Client.instance.find_drop("mydrop", "93mydroptoken97").should == mydrop
  end
end
