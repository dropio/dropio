require File.dirname(__FILE__) + '/../spec_helper'

describe Client do
  def mock_http(method, path, response)
    request_klass = {:get => Net::HTTP::Get}[method]
    request = mock(request_klass)
    request_klass.stub!(:new).with(path, an_instance_of(Hash)).and_return(request)
    
    http = mock(Net::HTTP)
    Net::HTTP.stub!(:new).with("api.drop.io").and_return(http)
    http.stub!(:start).and_yield(http)
    http.stub!(:request).with(request).and_return(response)
  end
  
  before(:each) do
    # Don't allow Net::HTTP::Get's to be created without being
    # specifically stubbed, typically with mock_http above.
    Net::HTTP::Get.stub!(:new).with do |*args|
      raise "Created an unexpected Net::HTTP::Get!\nNet::HTTP::Get.new(#{args.map { |e| e.inspect }.join(", ")})"
    end
    
    Dropio.api_url = "http://api.drop.io"
    Dropio.api_key = "43myapikey13"

    @api_response_body = stub("API Response Body")
    @api_response      = stub(Net::HTTPSuccess, :body => @api_response_body)

    @mydrop  = stub(Drop, :name => 'mydrop', :admin_token => '93mydroptoken97')
    @asset   = stub(Asset, :name => 'some_video', :drop => @mydrop)
    @comment = stub(Comment)
  end

  it "should find drops" do
    mock_http(:get, "/drops/mydrop?api_key=43myapikey13&token=93mydroptoken97&format=json", @api_response)
    Client::Mapper.should_receive(:map_drops).with(@api_response_body).and_return(@mydrop)
    Client.instance.find_drop("mydrop", "93mydroptoken97").should == @mydrop
  end
  
  it "should find assets" do
    mock_http(:get, %r|^/drops/mydrop/assets/\?api_key=43myapikey13&token=93mydroptoken97&format=json|, @api_response)
    Client::Mapper.should_receive(:map_assets).with(@mydrop, @api_response_body).and_return([@asset])
    Client.instance.find_assets(@mydrop).should == [@asset]
  end

  it "should find comments" do
    mock_http(:get, %r|^/drops/mydrop/assets/some_video/comments/\?api_key=43myapikey13&token=93mydroptoken97&format=json|, @api_response)
    Client::Mapper.should_receive(:map_comments).with(@asset, @api_response_body).and_return([@comment])
    Client.instance.find_comments(@asset).should == [@comment]
  end
end
