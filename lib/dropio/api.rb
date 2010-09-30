require 'rbconfig'
require 'mime/types'
require 'httparty'
require 'net/http/post/multipart'

class Dropio::Api
  include HTTParty
  format :json
  
  RUBY_VERSION = %w{MAJOR MINOR TEENY}.map { |k| Config::CONFIG[k] }.join(".")
  USER_AGENT_STRING = "DropioAPI-Ruby/#{Dropio::VERSION} (Ruby #{RUBY_VERSION} #{Config::CONFIG["host"]}; +http://github.com/dropio/dropio/tree/)"
  headers 'Accept' => 'application/json', 'User-Agent' => USER_AGENT_STRING, "content-type" => 'application/json'
  def initialize
    self.class.debug_output $stderr if Dropio::Config.debug
    self.class.base_uri Dropio::Config.api_url
    self.class.default_options[:timeout] = Dropio::Config.timeout
  end

  def drop(drop_name, token = nil)
    dropio_get("/drops/#{drop_name}", {:token => token})
  end
  
  def all_drops(page = 1)
    dropio_get("/accounts/drops", {:page => page})
  end
  
  def generate_drop_url(drop_name, token)
    signed_url(drop_name,token)
  end

  def create_drop(params = {})
    dropio_post("/drops",params)
  end

  def update_drop(drop_name, params = {})
    dropio_put("/drops/#{drop_name}", params)
  end
  
  def change_drop_name(drop_name, new_name)
    params = {:name => new_name}
    dropio_put("/drops/#{drop_name}", params)
  end
  
  def empty_drop(drop_name)
    dropio_put("/drops/#{drop_name}/empty", {})
  end

  def delete_drop(drop_name)
    dropio_delete("/drops/#{drop_name}", {})
  end
  
  def promote_nick(drop_name, nick)
    dropio_post("/drops/#{drop_name}", {:nick => nick})
  end
  
  def drop_upload_code(drop_name, token = nil)
    dropio_get("/drops/#{drop_name}/upload_code", {:token => token})
  end

  def create_link(drop_name, url, title = nil, description = nil, token = nil)
    dropio_post("/drops/#{drop_name}/assets", {:url => url, :title => title, :description => description, :token => token})
  end

  def create_note(drop_name, contents, title = nil, description = nil, token = nil)
    params = {:contents => contents, :title => title, :token => token, :description => description}
    dropio_post("/drops/#{drop_name}/assets", params)
  end

  def add_file(drop_name, file_path, description = nil, conversion = nil, pingback_url = nil, output_locations = nil)
    url  = URI.parse(Dropio::Config.upload_url)
    locs = output_locations.is_a?(Array) ? output_locations.join(',') : output_locations
    r    = nil

    File.open(file_path) do |file|
      mime_type = (MIME::Types.type_for(file_path)[0] || MIME::Types["application/octet-stream"][0])

      params = {
        :api_key => Dropio::Config.api_key.to_s,
        :format => 'json',
        :version           => Dropio::Config.version
      }
      
      # stuff passed in by a user. Done like this as if you pass a parameter without a value it can cause an issue (with the output_locations anyway)
      # although this will be fixed in the API, we shouldn't be doing it anyway.
      params[:drop_name] = drop_name if drop_name
      params[:description] = description if description
      params[:pingback_url] = pingback_url if pingback_url
      params[:output_locations] = locs if locs
      params[:conversion] = conversion if conversion
      params[:signature_mode] = "STRICT"
      #sign the params at this point
      params = sign_if_needed(params)
      params[:file]  = UploadIO.new(file, mime_type, file_path)
      
      req  = Net::HTTP::Post::Multipart.new(url.path, params)
      http = Net::HTTP.new(url.host, url.port)
      http.set_debug_output $stderr if Dropio::Config.debug
      r = http.start{|http| http.request(req)}
    end

    (r.nil? or r.body.nil? or r.body.empty?) ? r : HTTParty::Response.new(r,Crack::JSON.parse(r.body))
  end
  
  def add_file_from_url(drop_name, url, description = nil, convert_to = nil, pingback_url = nil, token = nil)
    dropio_post("/drops/#{drop_name}/assets", {:token => token, :file_url => url, :description => description, :convert_to => convert_to, :pingback_url => pingback_url})
  end

  def assets(drop_name, page = 1, order = :oldest, token = nil)
    dropio_get("/drops/#{drop_name}/assets", {:token => token, :page => page, :order => order.to_s, :show_pagination_details => true})
  end

  def asset(drop_name, asset_name, token = nil)
    dropio_get("/drops/#{drop_name}/assets/#{asset_name}", {:token => token})
  end
  
  def generate_asset_url(drop_name, asset_name, token)
    signed_url(drop_name, token, asset_name)
  end
  
  def generate_original_file_url(drop_name, asset_name, time_to_live = 600)
    #TODO - signed download URLs
    #this is now available via the API response itself
    download_url = Dropio::Config.api_url + "/drops/#{drop_name}/assets/#{asset_name}/download/original?"
    params = {:version => Dropio::Config.version, :api_key=>Dropio::Config.api_key.to_s, :format=>'json'}
    params = sign_if_needed(params)
    paramstring = ''
    params.each do |k, v|
      paramstring << "#{k}=#{v}&"
    end
    paramstring.chop!
    download_url += paramstring
  end

  def asset_embed_code(drop_name, asset_name, token = nil)
    dropio_get("/drops/#{drop_name}/assets/#{asset_name}/embed_code", {:token => token})
  end

  def update_asset(drop_name, asset_name, params = {}, token = nil)
    params[:token] = token
    dropio_put("/drops/#{drop_name}/assets/#{asset_name}", params)
  end
  
  def change_asset_name(drop_name, asset_name, token, new_name)
    params = {:token => token, :name => new_name}
    dropio_put("/drops/#{drop_name}/assets/#{asset_name}", params)
  end

  def delete_asset(drop_name, asset_name)
    dropio_delete("/drops/#{drop_name}/assets/#{asset_name}", {})
  end

  def delete_role(drop_name, asset_name, role, location=nil)
    dropio_delete("/drops/#{drop_name}/assets/#{asset_name}", {:role => role, :output_location => location})
  end

  def send_asset_to_drop(drop_name, asset_name, target_drop, drop_token = nil, token = nil)
    dropio_post("/drops/#{drop_name}/assets/#{asset_name}/send_to", {:medium => "drop", :drop_name => target_drop, :token => token, :drop_token => drop_token})
  end
  
  def copy_asset(drop_name, asset_name, target_drop, target_drop_token, token = nil)
    params = {:token => token, :drop_name => target_drop, :drop_token => target_drop_token}
    dropio_post("/drops/#{drop_name}/assets/#{asset_name}/copy", params)
  end
  
  def move_asset(drop_name, asset_name, target_drop, target_drop_token, token = nil)
    params = {:token => token, :drop_name => target_drop, :drop_token => target_drop_token}
    dropio_post("/drops/#{drop_name}/assets/#{asset_name}/move", params)
  end

  def create_pingback_subscription(drop_name, url, events = {}, token = nil)
    dropio_post("/drops/#{drop_name}/subscriptions", :body => { :token => token, :type => "pingback", :url => url}.merge(events))
  end
  
  def subscriptions(drop_name, page)
    dropio_get("/drops/#{drop_name}/subscriptions", :query => {:page => page, :show_pagination_details => true})
  end
  
  def delete_subscription(drop_name, subscription_id)
    dropio_delete("/drops/#{drop_name}/subscriptions/#{subscription_id}", {})
  end
  
  def get_signature(params={})
    #returns a signature for the passed params, without any modifcation to the params
    params = sign_request(params)
    params[:signature]
  end
  
  def job(id, drop_name, asset_name_or_id, token=nil)
    dropio_get("/drops/#{drop_name}/assets/#{asset_name_or_id}/jobs/#{id}", {:token => token})
  end

  def create_job(job = {})
    dropio_post("/jobs",job)
  end
  alias_method :convert, :create_job
  
  private
  
  def sign_request(params={})
    #returns all params, including signature and any required params for signing (currently only timestamp)
    params_for_sig = params.clone
    params_for_sig[:api_key] = Dropio::Config.api_key.to_s
    params_for_sig[:version] = Dropio::Config.version.to_s
    
    if params[:signature_mode] != "OPEN"
      #RPC always includes format here, so in NORMAL and STRICT mode we need to include it in our sig if not specified
      params_for_sig[:format] ||= 'json'
      params[:format] ||= 'json'
    end
    
    paramstring = ''
    params_for_sig.keys.sort_by {|s| s.to_s}.each {|key| paramstring +=  key.to_s + '=' +  params_for_sig[key].to_s}
    params[:signature] = Digest::SHA1.hexdigest(paramstring + Dropio::Config.api_secret)
    params
  end
  
  def sign_if_needed(params = {})
    if Dropio::Config.api_secret
      params = add_required_signing_params(params)
      params = sign_request(params)
      params
    else
      params
    end
  end
    
  def add_required_signing_params(params = {})
    #10 minute window
    params[:timestamp] = (Time.now.to_i + 600).to_s
    params
  end
  
  def add_default_params(params = {})
    default_params = {:api_key => Dropio::Config.api_key.to_s, :version => Dropio::Config.version.to_s, :format => "json" }
    params = params.merge(default_params)
    params
  end
  
  def dropio_get(action, params={})
    self.class.get(action, :query => add_default_params(sign_if_needed(params)))
  end
  
  def dropio_post(action, params={})
    self.class.post(action, :body => add_default_params(sign_if_needed(params)).to_json)
  end
  
  def dropio_put(action, params={})
    self.class.put(action, :body => add_default_params(sign_if_needed(params)).to_json)
  end
  
  def dropio_delete(action,params={})
    self.class.delete(action, :body => add_default_params(sign_if_needed(params)).to_json)
  end
  
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