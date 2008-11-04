class Dropio::Client

  # Takes a drop name and optional token and returns a +Drop+ or errors.
  def find_drop(drop_name, token = nil)
    uri = URI::HTTP.build({:path => drop_path(drop_name), :query => get_request_tokens(token)})
    req = Net::HTTP::Get.new(uri.request_uri, DEFAULT_HEADER)
    drop = nil
    complete_request(req) { |body| drop = Mapper.map_drops(body) }
    drop
  end
  
  # Finds a collection of +Asset+ objects for a given +Drop+.
  def find_assets(drop, page = 1)
    token = get_default_token(drop)
    uri = URI::HTTP.build({:path => asset_path(drop), :query => get_request_tokens(token) + "&page=#{page}"})
    req = Net::HTTP::Get.new(uri.request_uri, DEFAULT_HEADER)
    assets = nil
    complete_request(req) { |body| assets = Mapper.map_assets(drop, body) }
    assets
  end
  
  # Finds a collection of +Comment+ objects for a given +Asset+.
  def find_comments(asset)
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => comment_path(asset.drop, asset), :query => get_request_tokens(token)})
    req = Net::HTTP::Get.new(uri.request_uri, DEFAULT_HEADER)
    comments = nil
    complete_request(req) { |body| comments = Mapper.map_comments(asset, body) }
    comments
  end
  
  # Creates a drop with an +attributes+ hash.
  # Valid attributes: name (string), guests_can_comment (boolean), guests_can_add (boolean), guests_can_delete (boolean), expiration_length (string), password (string), admin_password (string), and premium_code (string)
  # Descriptions can be found here: http://groups.google.com/group/dropio-api/web/full-api-documentation
  def create_drop(attributes = {})
    uri = URI::HTTP.build({:path => drop_path})
    form = create_form(attributes)
    req = Net::HTTP::Post.new(uri.request_uri, DEFAULT_HEADER)
    req.set_form_data(form)
    drop = nil
    complete_request(req) { |body| drop = Mapper.map_drops(body) }
    drop
  end
  
  # Saves a +Drop+ back to drop.io
  def save_drop(drop)
    uri = URI::HTTP.build({:path => drop_path(drop) })
    token = get_admin_token(drop)
    form = create_form({ :token => token, :expiration_length => drop.expiration_length, :guests_can_comment => drop.guests_can_comment, :guests_can_add => drop.guests_can_add, :guests_can_delete => drop.guests_can_delete })
    req = Net::HTTP::Put.new(uri.request_uri, DEFAULT_HEADER)
    req.set_form_data(form)
    drop = nil
    complete_request(req) { |body| drop = Mapper.map_drops(body) }
    drop
  end
  
  # Destroys a +Drop+
  def destroy_drop(drop)
    token = get_admin_token(drop)
    uri = URI::HTTP.build({:path => drop_path(drop)})
    form = create_form( { :token => token })
    req = Net::HTTP::Delete.new(uri.request_uri, DEFAULT_HEADER)
    req.set_form_data(form)
    complete_request(req)
    true
  end
  
  # Adds a file to a +Drop+
  def add_file(drop, file_path)
    token = get_default_token(drop)
    
    File.open(file_path, 'r') do |file|
      uri = URI.parse(Dropio.upload_url)
      req = Net::HTTP::Post.new(uri.path)
      form = create_form( { :drop_name => drop.name, :token => token , :file => file } )
      req.multipart_params = form
      complete_request(req, uri.host)
    end
    
    true
  end
  
  # Creates a note +Asset+
  def create_note(drop, title, contents)
    token = get_default_token(drop)
    uri = URI::HTTP.build({:path => asset_path(drop)})
    form = create_form( { :token => token, :title => title, :contents => contents })
    req = Net::HTTP::Post.new(uri.request_uri, DEFAULT_HEADER)
    req.set_form_data(form)
    asset = nil
    complete_request(req) { |body| asset = Mapper.map_assets(drop, body) }
    asset
  end
  
  # Creates a link +Asset+
  def create_link(drop, url, title = nil, contents = nil)
    token = get_default_token(drop)
    uri = URI::HTTP.build({:path => asset_path(drop)})
    form = create_form( { :token => token, :url => url, :title => title, :contents => contents })
    req = Net::HTTP::Post.new(uri.request_uri, DEFAULT_HEADER)
    req.set_form_data(form)
    asset = nil
    complete_request(req) { |body| asset = Mapper.map_assets(drop, body) }
    asset
  end
  
  # Saves a +Comment+, requires admin token.
  def save_comment(comment)
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => comment_path(asset.drop, asset, comment)})
    form = create_form( { :token => token, :contents => contents })
    req = Net::HTTP::Put.new(uri.request_uri, DEFAULT_HEADER)
    req.set_form_data(form)
    comment = nil
    complete_request(req) { |body| comment = Mapper.map_comments(asset, body) }
    comment
  end
  
  # Destroys a +Comment+, requires admin token.
  def destroy_comment(comment)
    token = get_admin_token(comment.asset.drop)
    uri = URI::HTTP.build({:path => comment_path(comment.asset.drop, comment.asset, comment)})
    form = create_form( { :token => token })
    req = Net::HTTP::Delete.new(uri.request_uri, DEFAULT_HEADER)
    req.set_form_data(form)
    complete_request(req)
    true
  end
  
  # Creates a +Comment+
  def create_comment(asset, contents)
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => comment_path(asset.drop, asset)})
    form = create_form( { :token => token, :contents => contents })
    req = Net::HTTP::Post.new(uri.request_uri, DEFAULT_HEADER)
    req.set_form_data(form)
    comment = nil
    complete_request(req) { |body| comment = Mapper.map_comments(asset, body) }
    comment
  end
  
  # Sends an +Asset+ (of type Document) to a +fax_number+
  def send_to_fax(asset, fax_number)
    params = { :medium => "fax", :fax_number => fax_number }
    send_asset(asset,params)
  end
  
  # Sends an email +message+, containing the +asset+ to a list of +emails+
  def send_to_emails(asset, emails = [], message = nil)
    params = { :medium => "drop", :emails => emails.join(","), :message => message }
    send_asset(asset,params)
  end
  
  # Sends an +Asset+ to a given +Drop+ with +drop_name+
  def send_to_drop(asset, drop_name)
    params = { :medium => "drop", :drop_name => drop_name }
    send_asset(asset,params)
  end
  
  # Saves an +Asset+ back to drop.io
  def save_asset(asset)
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => asset_path(asset.drop, asset)})
    form = create_form({ :token => token, 
                         :title => asset.title,
                         :url => asset.url,
                         :description => asset.description,
                         :contents => asset.contents })
    req = Net::HTTP::Put.new(uri.request_uri, DEFAULT_HEADER)
    req.set_form_data(form)
    asset = nil
    complete_request(req) { |body| asset = Mapper.map_assets(asset.drop, body)}
    asset
  end
  
  # Destroys an +Asset+
  def destroy_asset(asset)
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => asset_path(asset.drop, asset)})
    form = create_form( { :token => token })
    req = Net::HTTP::Delete.new(uri.request_uri, DEFAULT_HEADER)
    req.set_form_data(form)
    complete_request(req)
    true
  end
  
  # Generates the authenticated +Drop+ url.
  def generate_drop_url(drop)
    signed_url(drop)
  end
  
  # Generates the authenticated +Asset+ url.
  def generate_asset_url(asset)
    signed_url(asset.drop, asset)
  end
  
  protected
  
  def signed_url(drop, asset = nil)
    # 10 minute window.
    expires = (Time.now.utc + 10*60).to_i
    token = get_default_token(drop)
    path = Dropio.base_url + "/#{drop.name}"
    path += "/asset/#{asset.name}" if asset
    path += "/from_api"
    sig = Digest::SHA1.hexdigest("#{expires}+#{token}+#{drop.name}")
    path + "?expires=#{expires}&signature=#{sig}"
  end
  
  def create_form(options = {})
    { :api_key => Dropio.api_key, :format => 'json', :version => '1.0' }.merge(options)
  end
  
  def send_asset(asset, params = {})
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => send_to_path(asset.drop, asset)})
    form = create_form( { :token => token }.merge(params) )
    req = Net::HTTP::Post.new(uri.request_uri, DEFAULT_HEADER)
    req.set_form_data(form)
    complete_request(req)
    true
  end
  
  def get_default_token(drop)
    drop.admin_token || drop.guest_token
  end
  
  def get_admin_token(drop)
    drop ? drop.admin_token : nil
  end
  
  def get_request_tokens(token = '')
    "api_key=#{Dropio.api_key}&token=#{token}&version=1.0&format=json"
  end

end