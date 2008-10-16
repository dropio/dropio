class Dropio::Client

  # Takes a drop name and optional token and returns a +Drop+ or errors.
  def find_drop(drop_name, token = nil)
    uri = URI::HTTP.build({:path => drop_path(drop_name), :query => get_request_tokens(token)})
    req = Net::HTTP::Get.new(uri.request_uri, default_header)
    complete_request(req) { |body| Mapper.map_drops(body) }
  end
  
  # Finds a collection of +Asset+ objects for a given +Drop+.
  def find_assets(drop)
    token = get_default_token(drop)
    uri = URI::HTTP.build({:path => asset_path(drop), :query => get_request_tokens(token)})
    req = Net::HTTP::Get.new(uri.request_uri, default_header)
    complete_request(req) { |body| Mapper.map_assets(drop, body) }
  end
  
  # Finds a collection of +Comment+ objects for a given +Asset+.
  def find_comments(asset)
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => comment_path(asset.drop, asset), :query => get_request_tokens(token)})
    req = Net::HTTP::Get.new(uri.request_uri, default_header)
    complete_request(req) { |body| Mapper.map_comments(asset, body) }
  end
  
  # Creates +Drop+ with +attributes+: :url, :password, :admin_password, :premium_code
  # :private_type, :expiration_length, :delete_permission_type
  def create_drop(attributes = {})
    uri = URI::HTTP.build({:path => drop_path})
    form = create_form({ :token => token }.merge(attributes))
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(form)
    complete_request(req) { |body| Mapper.map_drops(body) }
  end
  
  # Saves a +Drop+ back to drop.io
  def save_drop(drop)
    uri = URI::HTTP.build({:path => drop_path(drop) })
    form = create_form({ :token => token }.merge(drop.attributes))
    req = Net::HTTP::Put.new(uri.request_uri)
    req.set_form_data(form)
    complete_request(req) { |body| Mapper.map_drops(body) }
  end
  
  # Destroys a +Drop+
  def destroy_drop(drop)
    token = get_admin_token(drop)
    uri = URI::HTTP.build({:path => drop_path(drop)})
    form = create_form( { :token => token })
    req = Net::HTTP::Delete.new(uri.request_uri)
    req.set_form_data(form)
    complete_request(req)
  end
  
  # Adds a file to a +Drop+
  def add_file(drop, file)
    token = get_admin_token(drop)
    file_data = File.read(file) if File.exists?(file)
    uri = URI.parse(Dropio.upload_url)
    req = Net::HTTP::Post.new(url.path)
    File.open(@attributes[:file]) do |file|
      form = create_form( { :token => token , :file => file_data })
      req.multipart_params form
      complete_request(req)
    end
  end
  
  # Creates a note +Asset+
  def create_note(drop, title, contents)
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => asset_path(drop)})
    form = create_form( { :token => token, :title => title, :contents => contents })
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(form)
    complete_request(req) { |body| Mapper.map_assets(asset, body) }
  end
  
  # Creates a link +Asset+
  def create_link(drop, url, title = nil, contents = nil)
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => asset_path(drop)})
    form = create_form( { :token => token, :url => url, :title => title, :contents => contents })
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(form)
    complete_request(req) { |body| Mapper.map_assets(asset, body) }
  end
  
  # Saves a +Comment+, requires admin token.
  def save_comment(comment)
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => comment_path(asset.drop, asset, comment)})
    form = create_form( { :token => token, :contents => contents })
    req = Net::HTTP::Put.new(uri.request_uri)
    req.set_form_data(form)
    complete_request(req) { |body| Mapper.map_comments(asset, body) }
  end
  
  # Destroys a +Comment+, requires admin token.
  def destroy_comment(comment)
    token = get_admin_token(comment.asset.drop)
    uri = URI::HTTP.build({:path => comment_path(comment.asset.drop, comment.asset, comment)})
    form = create_form( { :token => token })
    req = Net::HTTP::Delete.new(uri.request_uri)
    req.set_form_data(form)
    complete_request(req)
  end
  
  # Creates a +Comment+
  def create_comment(asset, contents)
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => comment_path(asset.drop, asset)})
    form = create_form( { :token => token, :contents => contents })
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(form)
    complete_request(req) { |body| Mapper.map_comments(asset, body) }
  end
  
  # Sends an +Asset+ (of type Document) to a +fax_number+
  def send_to_fax(asset, fax_number)
    params = { :medium => "fax", :fax_number => fax_number }
    send(asset,params)
  end
  
  # Sends an email +message+, containing the +asset+ to a list of +emails+
  def send_to_emails(asset, emails = [], message)
    params = { :medium => "drop", :emails => emails.join(","), :message => message }
    send(asset,params)
  end
  
  # Sends an +Asset+ to a given +Drop+ with +drop_name+
  def send_to_drop(asset, drop_name)
    params = { :medium => "drop", :drop_name => drop_name }
    send(asset,params)
  end
  
  # Saves an +Asset+ back to drop.io
  def save_asset(asset)
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => asset_path(asset.drop, asset)})
    form = create_form( { :token => token, :name => asset.name })
    req = Net::HTTP::Delete.new(uri.request_uri)
    req.set_form_data(form)
    complete_request(req) { |body| Mapper.map_assets(asset.drop, body)}
  end
  
  # Destroys an +Asset+
  def destroy_asset(asset)
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => asset_path(asset.drop, asset)})
    form = create_form( { :token => token })
    req = Net::HTTP::Delete.new(uri.request_uri)
    req.set_form_data(form)
    complete_request(req)
  end
  
  protected
  
  def create_form(options = {})
    { :api_key => Dropio.api_key }.merge(options)
  end
  
  def send(asset, params = {})
    token = get_default_token(asset.drop)
    uri = URI::HTTP.build({:path => send_to_path(asset.drop, asset)})
    form = create_form( { :token => token }.merge(params) )
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(form)
    complete_request(req)
  end
  
  def get_default_token(drop)
    (drop.admin_token) ? drop.admin_token : drop.user_token
  end
  
  def get_admin_token(drop)
    drop ? drop.admin_token : nil
  end
  
  def get_request_tokens(token = '')
    "api_key=#{Dropio.api_key}&token=#{token}&format=json"
  end

end