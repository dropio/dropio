require File.dirname(__FILE__) + '/../spec_helper'

describe Client do
  before(:each) do
    Dropio.api_url = "http://api.drop.io"
    Dropio.api_key = "43myapikey13"

    @api_response_body = stub("API Response Body")
    @api_response      = stub("API Response", :body => @api_response_body)

    @mydrop  = stub(Drop, :name => 'mydrop', :admin_token => '93mydroptoken97')
    @asset   = stub(Asset, :name => 'some_video', :drop => @mydrop)
    @comment = stub(Comment)
  end

  it "should find drops" do
    Net::HTTP.should_receive(:get_response).
              with(URI("http://api.drop.io/drops/mydrop?api_key=43myapikey13&token=93mydroptoken97&format=json")).
              and_return(@api_response)

    Client::Mapper.should_receive(:map_drops).with(@api_response_body).and_return(@mydrop)
    
    Client.instance.find_drop("mydrop", "93mydroptoken97").should == @mydrop
  end
  
  it "should find assets" do
    Net::HTTP.should_receive(:get_response).
              with(URI("http://api.drop.io/drops/mydrop/assets/?api_key=43myapikey13&token=93mydroptoken97&format=json")).
              and_return(@api_response)

    Client::Mapper.should_receive(:map_assets).with(@mydrop, @api_response_body).and_return([@asset])
    
    Client.instance.find_assets(@mydrop).should == [@asset]
  end

  it "should find comments" do
    Net::HTTP.should_receive(:get_response).
              with(URI("http://api.drop.io/drops/mydrop/assets/some_video/comments/?api_key=43myapikey13&token=93mydroptoken97&format=json")).
              and_return(@api_response)

    Client::Mapper.should_receive(:map_comments).with(@asset, @api_response_body).and_return([@comment])
    
    Client.instance.find_comments(@asset).should == [@comment]
  end
end
