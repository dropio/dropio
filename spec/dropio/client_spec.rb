require File.dirname(__FILE__) + '/../spec_helper'

describe Client do
  def mock_http(method, path, response, form_data = nil)
    request_klass = { :get  => Net::HTTP::Get,
                      :post => Net::HTTP::Post,
                      :put  => Net::HTTP::Put }[method]
    raise "Don't know how to mock a #{method.inspect} HTTP call." if request_klass.nil?
    request = mock(request_klass)
    request.should_receive(:set_form_data).with(form_data) if form_data
    request_klass.stub!(:new).with(path, Client::DEFAULT_HEADER).and_return(request)
    
    http = mock(Net::HTTP)
    Net::HTTP.stub!(:new).with("api.drop.io").and_return(http)
    http.stub!(:start).and_yield(http)
    http.stub!(:request).with(request).and_return(response)
  end
  
  def stub_asset(more_stubs={})
    stub Asset, [:drop, :name, :type, :title, :description, :filesize, :created_at,
                 :thumbnail, :status, :file, :converted, :hidden_url, :pages,
                 :duration, :artist, :track_title, :height, :width, :contents, :url].
                   inject({}) { |stubs, key| stubs[key] = nil; stubs }.merge(more_stubs)
  end
  
  before(:each) do
    # Don't allow HTTPRequests to be created without being
    # specifically stubbed, typically with mock_http above.
    [Net::HTTP::Get, Net::HTTP::Post, Net::HTTP::Put].each do |request_klass|
      request_klass.stub!(:new).with do |*args|
        raise "Created an unexpected #{request_klass}!\n#{request_klass}.new(#{args.map { |e| e.inspect }.join(", ")})"
      end
    end
    
    Dropio.api_url = "http://api.drop.io"
    Dropio.api_key = "43myapikey13"
    
    @api_response_body = stub("API Response Body")
    @api_response      = stub(Net::HTTPSuccess, :body => @api_response_body)
    
    @mydrop     = stub(Drop, :name => 'mydrop', :admin_token => '93mydroptoken97')
    @note       = stub_asset(:drop => @mydrop, :name => 'a-note', :contents => "My thoughts on life.")
    @link       = stub_asset(:drop => @mydrop, :name => 'a-link', :url => "http://google.com/")
    @file_asset = stub_asset(:drop => @mydrop, :name => 'some-video')
    @comment    = stub(Comment)
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
    
    mock_http(:post, "/drops/", @api_response, settings.merge(:api_key => "43myapikey13", :format => "json", :version => "1.0"))
    Client::Mapper.stub!(:map_drops).with(@api_response_body).and_return(@mydrop)
    Client.instance.create_drop(settings).should == @mydrop
  end
  
  it "should create notes" do
    mock_http(:post, "/drops/mydrop/assets/", @api_response, :title    => "Just a Note",
                                                             :contents => "This is just to say",
                                                             :token    => "93mydroptoken97",
                                                             :api_key  => "43myapikey13",
                                                             :format   => "json",
                                                             :version  => "1.0")
    Client::Mapper.stub!(:map_assets).with(@mydrop, @api_response_body).and_return(@note)
    Client.instance.create_note(@mydrop, "Just a Note", "This is just to say").should == @note
  end
  
  it "should create links" do
    mock_http(:post, "/drops/mydrop/assets/", @api_response, :url         => "http://drop.io/",
                                                             :title       => "Drop.io",
                                                             :description => "An awesome sharing site.",
                                                             :token       => "93mydroptoken97",
                                                             :api_key     => "43myapikey13",
                                                             :format      => "json",
                                                             :version     => "1.0")
    Client::Mapper.stub!(:map_assets).with(@mydrop, @api_response_body).and_return(@link)
    Client.instance.create_link(@mydrop, "http://drop.io/", "Drop.io", "An awesome sharing site.").should == @link
  end
  
  it "should create comments" do
    comment = stub(Comment)
    mock_http(:post, "/drops/mydrop/assets/some-video/comments/", @api_response,
                                                                  :contents => "What a cool video!",
                                                                  :token    => "93mydroptoken97",
                                                                  :api_key  => "43myapikey13",
                                                                  :format   => "json",
                                                                  :version  => "1.0")
    Client::Mapper.stub!(:map_comments).with(@file_asset, @api_response_body).and_return(comment)
    Client.instance.create_comment(@file_asset, "What a cool video!").should == comment
  end
  
  it "should find drops" do
    mock_http(:get, "/drops/mydrop?api_key=43myapikey13&token=93mydroptoken97&version=1.0&format=json", @api_response)
    Client::Mapper.stub!(:map_drops).with(@api_response_body).and_return(@mydrop)
    Client.instance.find_drop("mydrop", "93mydroptoken97").should == @mydrop
  end
  
  it "should find assets" do
    mock_http(:get, %r|^/drops/mydrop/assets/\?api_key=43myapikey13&token=93mydroptoken97&version=1.0&format=json|, @api_response)
    Client::Mapper.stub!(:map_assets).with(@mydrop, @api_response_body).and_return([@file_asset])
    Client.instance.find_assets(@mydrop).should == [@file_asset]
  end
  
  it "should find comments" do
    mock_http(:get, %r|^/drops/mydrop/assets/some-video/comments/\?api_key=43myapikey13&token=93mydroptoken97&version=1.0&format=json|, @api_response)
    Client::Mapper.stub!(:map_comments).with(@file_asset, @api_response_body).and_return([@comment])
    Client.instance.find_comments(@file_asset).should == [@comment]
  end
  
  it "should save drops" do
    @mydrop.stub!(:guests_can_comment => true,
                  :guests_can_add     => false,
                  :guests_can_delete  => false,
                  :expiration_length  => "1_WEEK_FROM_LAST_VIEW",
                  :password           => "mazda",
                  :admin_password     => "foo64bar",
                  :premium_code       => "yeswecan")
    
    mock_http(:put, "/drops/mydrop", @api_response,
                                     :guests_can_comment => true,
                                     :guests_can_add     => false,
                                     :guests_can_delete  => false,
                                     :expiration_length  => "1_WEEK_FROM_LAST_VIEW",
                                     :password           => "mazda",
                                     :admin_password     => "foo64bar",
                                     :premium_code       => "yeswecan",
                                     :token              => "93mydroptoken97",
                                     :api_key            => "43myapikey13",
                                     :format             => "json",
                                     :version            => "1.0")
    
    new_drop = stub(Drop)
    Client::Mapper.stub!(:map_drops).with(@api_response_body).and_return(new_drop)
    Client.instance.save_drop(@mydrop).should == new_drop
  end
  
  it "should save note assets" do
    @note.stub!(:title    => "Just a Note",
                :contents => "This is just to say")
    
    mock_http(:put, "/drops/mydrop/assets/a-note", @api_response,
                                                   :title       => "Just a Note",
                                                   :description => nil,
                                                   :url         => nil,
                                                   :contents    => "This is just to say",
                                                   :token       => "93mydroptoken97",
                                                   :api_key     => "43myapikey13",
                                                   :format      => "json",
                                                   :version     => "1.0")
    
    new_note = stub_asset
    Client::Mapper.stub!(:map_assets).with(@mydrop, @api_response_body).and_return(new_note)
    Client.instance.save_asset(@note).should == new_note
  end

  it "should save link assets" do
    @link.stub!(:url         => "http://drop.io/",
                :title       => "Drop.io",
                :description => "An awesome sharing site.")
    
    mock_http(:put, "/drops/mydrop/assets/a-link", @api_response,
                                                   :title       => "Drop.io",
                                                   :description => "An awesome sharing site.",
                                                   :url         => "http://drop.io/",
                                                   :contents    => nil,
                                                   :token       => "93mydroptoken97",
                                                   :api_key     => "43myapikey13",
                                                   :format      => "json",
                                                   :version     => "1.0")
    
    new_link = stub_asset
    Client::Mapper.stub!(:map_assets).with(@mydrop, @api_response_body).and_return(new_link)
    Client.instance.save_asset(@link).should == new_link
  end

  it "should save file assets" do
    @file_asset.stub!(:title       => "Snowboarding in March",
                      :description => "This was really fun.")
    
    mock_http(:put, "/drops/mydrop/assets/some-video", @api_response,
                                                       :title       => "Snowboarding in March",
                                                       :description => "This was really fun.",
                                                       :url         => nil,
                                                       :contents    => nil,
                                                       :token       => "93mydroptoken97",
                                                       :api_key     => "43myapikey13",
                                                       :format      => "json",
                                                       :version     => "1.0")
    
    new_file_asset = stub_asset
    Client::Mapper.stub!(:map_assets).with(@mydrop, @api_response_body).and_return(new_file_asset)
    Client.instance.save_asset(@file_asset).should == new_file_asset
  end
end
