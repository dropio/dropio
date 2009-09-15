require 'rbconfig'

class Dropio::Api
  include HTTParty
  format :json
  
  RUBY_VERSION = %w{MAJOR MINOR TEENY}.map { |k| Config::CONFIG[k] }.join(".")
  USER_AGENT_STRING = "DropioAPI-Ruby/#{Dropio::VERSION} (Ruby #{RUBY_VERSION} #{Config::CONFIG["host"]}; +http://github.com/dropio/dropio/tree/)"
  headers 'Accept' => 'application/json', 'User-Agent' => USER_AGENT_STRING

  def initialize
    self.class.default_params :api_key => Dropio::Config.api_key, :version => Dropio::Config.version, :format => "json"
    self.class.base_uri Dropio::Config.api_url
  end

  def drop(drop_name, token = nil)
    self.class.get("/drops/#{drop_name}", :query => {:token => token})
  end
  
  def generate_drop_url(drop_name, token)
    signed_url(drop_name,token)
  end

  def create_drop(params = {})
    self.class.post("/drops",:body => params)
  end

  def update_drop(drop_name, params = {}, token = nil)
    params[:token] = token
    self.class.put("/drops/#{drop_name}", :body => params)
  end

  def delete_drop(drop_name, admin_token)
    params = {:token => admin_token}
    self.class.delete("/drops/#{drop_name}", :query => params)
  end

  def create_link(drop_name, url, title = nil, description = nil, token = nil)
    params = {:url => url, :title => title, :description => description, :token => token}
    self.class.post("/drops/#{drop_name}/assets", :body => params)
  end

  def create_note(drop_name, contents, title = nil, token = nil)
    params = {:contents => contents, :title => title, :token => token}
    self.class.post("/drops/#{drop_name}/assets", :body => params)
  end

  def add_file(drop_name, file_path, token = nil)
    url = URI.parse("http://assets.drop.io/upload/")
    r = nil
    File.open(file_path) do |file|
      mime_type = (MIME::Types.type_for(file_path)[0] || MIME::Types["application/octet-stream"][0])
      req = Net::HTTP::Post::Multipart.new url.path,
      { 'api_key' => self.class.default_params[:api_key], 'drop_name' => drop_name, 'format' => 'json',
        'token' => token, 'version' => '1.0', 'file' => UploadIO.new(file, mime_type, File.basename(file_path)) }
      http = Net::HTTP.new(url.host, url.port)
      r = http.start{|http| http.request(req)}
    end

    (r.nil? or r.body.nil? or r.body.empty?) ? [] : Crack::JSON.parse(r.body)
  end

  def assets(drop_name, page = 1, token = nil)
    self.class.get("/drops/#{drop_name}/assets", :query => {:token => token, :page => page})
  end

  def asset(drop_name, asset_name, token = nil)
    self.class.get("/drops/#{drop_name}/assets/#{asset_name}", :query => {:token => token})
  end
  
  def generate_asset_url(drop_name, asset_name, token)
    signed_url(drop_name, token, asset_name)
  end

  def embed_code(drop_name, asset_name, token = nil)
    self.class.get("/drops/#{drop_name}/assets/#{asset_name}/embed_code", :query => {:token => token})
  end

  def update_asset(drop_name, asset_name, params = {}, token = nil)
    params[:token] = token
    self.class.put("/drops/#{drop_name}/assets/#{asset_name}", :body => params)
  end

  def delete_asset(drop_name, asset_name, token = nil)
    self.class.delete("/drops/#{drop_name}/assets/#{asset_name}", :body => {:token => token})
  end

  def send_asset_to_drop(drop_name, asset_name, target_drop, drop_token = nil, token = nil)
    params = {:medium => "drop", :drop_name => target_drop, :token => token, :drop_token => drop_token}
    self.class.post("/drops/#{drop_name}/assets/#{asset_name}/send_to", :body => params)
  end
  
  def send_asset_to_fax(drop_name, asset_name, fax_number, token = nil)
    params = {:medium => "fax", :fax_number => fax_number, :token => token}
    self.class.post("/drops/#{drop_name}/assets/#{asset_name}/send_to", :body => params)
  end
  
  def send_asset_to_emails(drop_name, asset_name, emails, message = nil, token = nil)
    params = {:medium => "emails", :emails => emails, message => message, :token => token}
    self.class.post("/drops/#{drop_name}/assets/#{asset_name}/send_to", :body => params)
  end

  def comments(drop_name, asset_name, token = nil)
    self.class.get("/drops/#{drop_name}/assets/#{asset_name}/comments", :query => {:token => token})
  end

  def create_comment(drop_name, asset_name, contents, token = nil)
    params = {:contents => contents, :token => token}
    self.class.post("/drops/#{drop_name}/assets/#{asset_name}/comments",:body => params)
  end

  def comment(drop_name, asset_name, comment_id, token = nil)
    self.class.get("/drops/#{drop_name}/assets/#{asset_name}/comments/#{comment_id}", :query => {:token => token})
  end

  def update_comment(drop_name, asset_name, comment_id, contents, token = nil)
    params = {:contents => contents, :token => token}
    self.class.put("/drops/#{drop_name}/assets/#{asset_name}/comments/#{comment_id}", :body => params)
  end

  def delete_comment(drop_name, asset_name, comment_id, token = nil)
    self.class.delete("/drops/#{drop_name}/assets/#{asset_name}/comments/#{comment_id}", :body => {:token => token})
  end
  
  private
  
  def signed_url(drop_name, token, asset_name = nil)
    # 10 minute window.
    expires = (Time.now.utc + 10*60).to_i
    path = Dropio::Config.base_url + "/#{drop_name}"
    path += "/asset/#{asset_name}" if asset_name
    path += "/from_api"
    sig = Digest::SHA1.hexdigest("#{expires}+#{token}+#{drop_name}")
    path + "?expires=#{expires}&signature=#{sig}"
  end
end