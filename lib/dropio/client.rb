class Dropio::Client
  attr_accessor :service
  
  def initialize
    self.service = Dropio::Api.new
  end
  
  def drop(drop_name, token = nil)
    handle(:drop, self.service.drop(drop_name, token))
  end
  
  def all_drops(page = 1)
    handle(:drops, self.service.all_drops(page))
  end
  
  def generate_drop_url(drop)
    self.service.generate_drop_url(drop.name,drop.default_token)
  end

  def create_drop(params = {})
    handle(:drop, self.service.create_drop(params))
  end
  
  def change_drop_name(drop, new_name)
    handle(:drop, self.service.change_drop_name(drop.name,new_name))
    drop.name = new_name
    drop
  end

  def update_drop(drop)
    params = { :description => drop.description, :admin_email => drop.admin_email,
               :email_key => drop.email_key, :chat_password => drop.chat_password, 
               :expiration_length => drop.expiration_length, :password => drop.password, 
               :admin_password => drop.admin_password }
    handle(:drop, self.service.update_drop(drop.name,params))
  end
  
  def empty_drop(drop)
    r = handle(:response, self.service.empty_drop(drop.name))
    r["result"]
  end

  def delete_drop(drop)
    r = handle(:response, self.service.delete_drop(drop.name))
    r["result"]
  end
  
  def promote_nick(drop,nick)
    r = handle(:response, self.service.promote_nick(drop.name,nick))
    r["result"]
  end
  
  def drop_upload_code(drop)
    r = handle(:response, self.service.drop_upload_code(drop.name,drop.default_token))
    r["upload_code"]
  end

  def create_link(drop, url, title = nil, description = nil)
    a = handle(:asset, self.service.create_link(drop.name, url, title, description, drop.default_token))
    a.drop = drop
    a
  end

  def create_note(drop, contents, title = nil, description = nil)
    a = handle(:asset, self.service.create_note(drop.name, contents, title, description, drop.default_token))
    a.drop = drop
    a
  end

  def add_file(drop, file_path, description = nil, convert_to = nil, pingback_url = nil, output_locations = nil)
    a = handle(:asset, self.service.add_file(drop.name, file_path, description, convert_to, pingback_url, output_locations))
    a.drop = drop
    a
  end
  
  def add_file_from_url(drop, url, description = nil, convert_to = nil, pingback_url = nil)
    a = handle(:asset, self.service.add_file_from_url(drop.name, url, description, convert_to, pingback_url, drop.default_token))
    a.drop = drop
    a
  end

  def assets(drop, page = 1, order = :oldest)
    assets = handle(:assets, self.service.assets(drop.name,page,order,drop.default_token))
    assets.each{|a| a.drop = drop}
    assets
  end

  def asset(drop, asset_name)
    a = handle(:asset, self.service.asset(drop.name,asset_name,drop.default_token))
    a.drop = drop
    a
  end
  
  def generate_asset_url(asset)
    self.service.generate_asset_url(asset.drop.name, asset.name, asset.drop.default_token)
  end
  
  def generate_original_file_url(asset)
    self.service.generate_original_file_url(asset.drop.name, asset.name, asset.drop.default_token)
  end

  def asset_embed_code(asset)
    r = handle(:response, self.service.asset_embed_code(asset.drop.name,asset.name,asset.drop.default_token))
    r["embed_code"]
  end

  def update_asset(asset)
    params = { :title => asset.title, :description => asset.description, :url => asset.url, :contents => asset.contents }
    a = handle(:asset, self.service.update_asset(asset.drop.name,asset.name,params,asset.drop.default_token))
    a.drop = asset.drop
    a
  end
  
  def change_asset_name(asset, new_name)
    handle(:asset, self.service.change_asset_name(asset.drop.name,asset.name,drop.default_token,new_name))
    asset.name = new_name
    asset
  end

  def delete_asset(asset)
    r = handle(:response, self.service.delete_asset(asset.drop.name,asset.name))
    r["result"]
  end

  def delete_role(asset, role, location=nil)
    r = handle(:response, self.service.delete_role(asset.drop.name,asset.name,role,location))
    r["result"]
  end

  def send_asset_to_drop(asset, target_drop)
    r = handle(:response, self.service.send_asset_to_drop(asset.drop.name, asset.name, target_drop.name, target_drop.default_token, asset.drop.default_token))
    r["result"]
  end
  
  def copy_asset(asset,target_drop)
    r = handle(:response, self.service.copy_asset(asset.drop.name,asset.name,target_drop.name,target_drop.default_token,asset.drop.default_token))
    r["result"]
  end

  def move_asset(asset,target_drop)
    r = handle(:response, self.service.move_asset(asset.drop.name,asset.name,target_drop.name,target_drop.default_token,asset.drop.default_token))
    r["result"]
  end

  def create_pingback_subscription(drop, url, events)
    s = handle(:subscription, self.service.create_pingback_subscription(drop.name, url, events, drop.default_token))
    s.drop = drop
    s
  end
  
  def subscriptions(drop, page = 1)
    subscriptions = handle(:subscriptions, self.service.subscriptions(drop.name,page))
    subscriptions.each{|s| s.drop = drop}
    subscriptions
  end
  
  def delete_subscription(subscription)
    r = handle(:response, self.service.delete_subscription(subscription.drop.name,subscription.id,subscription.drop.default_token))
    r["result"]
  end
  
  def job(id, drop_name, asset_name_or_id, token=nil)
    handle(:job, self.service.job(id, drop_name, asset_name_or_id, token))
  end
  
  def create_job(job = {})
    handle(:job, self.service.create_job(job))
  end
  
  private
  
  def handle(type, response)
    if response.code != 200
      parse_response(response)
    end
    
    case type
    when :drop then return Dropio::Drop.new(response)
    when :drops then return response['drops'].collect{|d| Dropio::Drop.new(d)}
    when :asset then return Dropio::Asset.new(response)
    when :assets then return response['assets'].collect{|a| Dropio::Asset.new(a)}
    when :subscription then return Dropio::Subscription.new(response)
    when :subscriptions then return response['subscriptions'].collect{|s| Dropio::Subscription.new(s)}
    when :job then return Dropio::Job.new(response)
    when :response then return parse_response(response)
    end
  end
  
  def parse_response(response)
    case response.code
    when 200 then return response
    when 400 then raise Dropio::RequestError, parse_error_message(response)
    when 403 then raise Dropio::AuthorizationError, parse_error_message(response)
    when 404 then raise Dropio::MissingResourceError, parse_error_message(response)
    when 500 then raise Dropio::ServerError, "There was a problem connecting to Drop.io."
    else
      raise "Received an unexpected HTTP response: #{response.code} #{response.body}"
    end
  end
  
  # Extracts the error message from the response for the exception.
  def parse_error_message(error_hash)
    if (error_hash && error_hash.is_a?(Hash) && error_hash["response"] && error_hash["response"]["message"])
      return error_hash["response"]["message"]
    else
      return "There was a problem connecting to Drop.io."
    end
  end
  
end