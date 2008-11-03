require File.dirname(__FILE__) + '/../spec_helper'

describe Client do
  def mock_http(method, path, response, form_data = nil)
    request_klass = {:get => Net::HTTP::Get, :post => Net::HTTP::Post}[method]
    request = mock(request_klass)
    request.should_receive(:set_form_data).with(form_data) if form_data
    request_klass.stub!(:new).with(path, Client::DEFAULT_HEADER).and_return(request)
    
    http = mock(Net::HTTP)
    Net::HTTP.stub!(:new).with("api.drop.io").and_return(http)
    http.stub!(:start).and_yield(http)
    http.stub!(:request).with(request).and_return(response)
  end
  
  before(:each) do
    # Don't allow HTTPRequests to be created without being
    # specifically stubbed, typically with mock_http above.
    [Net::HTTP::Get, Net::HTTP::Post].each do |request_klass|
      request_klass.stub!(:new).with do |*args|
        raise "Created an unexpected #{request_klass}!\n#{request_klass}.new(#{args.map { |e| e.inspect }.join(", ")})"
      end
    end
    
    Dropio.api_url = "http://api.drop.io"
    Dropio.api_key = "43myapikey13"

    @api_response_body = stub("API Response Body")
    @api_response      = stub(Net::HTTPSuccess, :body => @api_response_body)

    @mydrop  = stub(Drop, :name => 'mydrop', :admin_token => '93mydroptoken97')
    @note    = stub(Asset)
    @asset   = stub(Asset, :name => 'some_video', :drop => @mydrop)
    @comment = stub(Comment)
  end
  
  it "should create drops" do
    settings = {:name               => "mynewdrop",
                :admin_password     => "niftieradminpassword",
                :password           => "niftyguestpassword",
                :guests_can_comment => true,
                :guests_can_add     => true,
                :guests_can_delete  => false,
                :expiration_length  => "1_WEEK_FROM_NOW",
                :premium_code       => "yeswecan"}
    
    mock_http(:post, "/drops/", @api_response, settings.merge(:api_key => "43myapikey13", :format => "json"))
    Client::Mapper.should_receive(:map_drops).with(@api_response_body).and_return(@mydrop)
    Client.instance.create_drop(settings).should == @mydrop
  end
  
  it "should create notes" do
    mock_http(:post, "/drops/mydrop/assets/", @api_response, :title    => "Just a Note",
                                                             :contents => "This is just to say",
                                                             :token    => "93mydroptoken97",
                                                             :api_key  => "43myapikey13",
                                                             :format   => "json")
    Client::Mapper.should_receive(:map_assets).with(@mydrop, @api_response_body).and_return(@note)
    Client.instance.create_note(@mydrop, "Just a Note", "This is just to say").should == @note
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
