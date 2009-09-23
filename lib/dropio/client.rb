class Dropio::Client
  attr_accessor :service
  
  def initialize
    self.service = Dropio::Api.new
  end
  
  def drop(drop_name, token = nil)
    handle(:drop, self.service.drop(drop_name, token))
  end
  
  def generate_drop_url(drop)
    self.service.generate_drop_url(drop.name,drop.default_token)
  end

  def create_drop(params = {})
    handle(:drop, self.service.create_drop(params))
  end

  def update_drop(drop)
    params = { :description => drop.description, :admin_email => drop.admin_email,
               :email_key => drop.email_key, :default_view => drop.default_view,
               :chat_password => drop.chat_password, :guests_can_comment => drop.guests_can_comment,
               :guests_can_add => drop.guests_can_add, :guests_can_delete => drop.guests_can_delete,
               :expiration_length => drop.expiration_length, :password => drop.password,
               :admin_password => drop.admin_password, :premium_code => drop.premium_code }
    handle(:drop, self.service.update_drop(drop.name,drop.admin_token,params))
  end
  
  def empty_drop(drop)
    handle(:response, self.service.empty_drop(drop.name,drop.admin_token))
  end

  def delete_drop(drop)
    handle(:response, self.service.delete_drop(drop.name,drop.admin_token))
  end
  
  def promote_nick(drop,nick)
    handle(:response, self.service.promote_nick(drop.name,nick,drop.admin_token))
  end
  
  def drop_upload_code(drop)
    handle(:response, self.service.drop_upload_code(drop.name,drop.default_token))
  end

  def create_link(drop, url, title = nil, description = nil)
    handle(:asset, self.service.create_link(drop.name, url, title, description, drop.default_token))
  end

  def create_note(drop, contents, title = nil)
    handle(:asset, self.service.create_note(drop.name, contents, title, drop.default_token))
  end

  def add_file(drop, file_path, comment = nil)
    handle(:asset, self.service.add_file(drop.name, file_path, drop.default_token, comment))
  end
  
  def add_file_from_url(drop, url)
    handle(:asset, self.service.add_file_from_url(drop.name, url, drop.default_token))
  end

  def assets(drop,page = 1, order = :oldest)
    handle(:assets, self.service.assets(drop.name,page,order,drop.default_token))
  end

  def asset(drop, asset_name)
    handle(:asset, self.service.asset(drop.name,asset_name,drop.default_token))
  end
  
  def generate_asset_url(asset)
    self.service.generate_drop_url(asset.drop.name, asset.name, asset.drop.default_token)
  end

  def asset_embed_code(asset)
    handle(:response, self.service.asset_embed_code(asset.drop.name,asset.name,asset.drop.default_token))
  end

  def update_asset(asset)
    params = { :title => asset.title, :description => asset.description, :url => asset.url, :contents => asset.contents }
    handle(:asset, self.service.update_asset(asset.drop.name,asset.name,params,asset.drop.default_token))
  end

  def delete_asset(asset)
    handle(:response, self.service.delete_asset(asset.drop.name,asset.name,asset.drop.default_token))
  end

  def send_asset_to_drop(asset, target_drop)
    handle(:response, self.service.send_asset_to_drop(asset.drop.name, asset.name, target_drop.name, target_drop.default_token, asset.drop.default_token))
  end
  
  def send_asset_to_fax(asset, fax_number)
    handle(:response, self.service.send_asset_to_fax(asset.drop.name, asset.name, fax_number, asset.drop.default_token))
  end
  
  def send_asset_to_emails(asset, emails, message)
    handle(:response, self.service.send_asset_to_emails(asset.drop.name, asset.name, emails, message, asset.drop.default_token))
  end
  
  def copy_asset(asset,target_drop)
    handle(:response, self.service.copy_asset(asset.drop.name,asset.name,target_drop.name,target_drop.default_token,asset.drop.default_token))
  end

  def move_asset(asset,target_drop)
    handle(:response, self.service.move_asset(asset.drop.name,asset.name,target_drop.name,target_drop.default_token,asset.drop.default_token))
  end

  def comments(asset)
    handle(:comments, self.service.comments(asset.drop.name,asset.name,asset.drop.default_token))
  end

  def create_comment(asset, contents)
    handle(:comment, self.service.create_comment(asset.drop.name,asset.name,contents,asset.drop.default_token))
  end

  def comment(asset, comment_id)
    handle(:comment, self.service.comment(asset.drop.name,asset.name,comment_id,asset.drop.default_token))
  end

  def update_comment(comment)
    handle(:comment, self.service.update_comment(comment.asset.drop.name,comment.asset.name,comment.id,comment.contents,comment.asset.drop.admin_token))
  end

  def delete_comment(comment)
    handle(:response, self.service.delete_comment(comment.asset.drop.name,comment.asset.name,comment.id,comment.asset.drop.admin_token))
  end
  
  def create_twitter_subscription(drop, username,password, message, events)
    handle(:subscription, self.service.create_twitter_subscription(drop.name, username, password, message, events, drop.default_token))
  end
  
  def create_email_subscription(drop, emails, welcome_message, welcome_subject, welcome_from, message, events)
    handle(:subscription, self.service.create_email_subscription(drop.name, emails, welcome_message, welcome_subject, welcome_from, message, events, drop.default_token))
  end
  
  def subscriptions(drop)
    handle(:subscriptions, self.service.subscriptions(drop.name, drop.admin_token))
  end
  
  private
  
  def handle(type, response)
    if response.code != 200
      parse_response(response)
    end
    
    case type
    when :drop then return Dropio::Drop.new(response)
    when :asset then return Dropio::Asset.new(response)
    when :assets then return response.collect{|a| Dropio::Asset.new(a)}
    when :comment then return Comment.new(response)
    when :comments then return response.collect{|c| Dropio::Comment.new(c)}
    when :subscription then return Dropio::Subscription.new(response)
    when :subscriptions then return response.collect{|s| Dropio::Subscription.new(s)}
    when :response then return parse_response(response)
    end
  end
  
  def parse_response(response)
    case response.code
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