class Dropio::Client
  include Singleton
  
  protected
  
  # Creates a path directly to a comment resource or a collection of comments.
  def comment_path(drop, asset, comment = nil)
    comment_id = (comment) ? comment.id.to_s : ''
    return asset_path(drop,asset) + "/comments/" + comment_id
  end
  
  # Creates a path directly to an asset resource or collection of assets.
  def asset_path(drop, asset = nil)
    asset_name = (asset) ? asset.name : ''
    return drop_path(drop) + "/assets/" + asset_name
  end
  
  # Creates a path directly to a drop resource or collection of drops.
  def drop_path(drop)
    if drop.is_a?(Dropio::Drop)
      drop_name = drop.name
    elsif drop.is_a?(String)
      drop_name = drop
    else
      drop_name = ''
    end
    
    return "/drops/" + drop_name
  end
  
  # Creates a path for sending an +Asset+
  def send_to_path(drop, asset)
    return asset_path(asset) + "/send_to"
  end
  
  # Returns a default set of headers for each request.
  def default_header
    @@http_header ||= {
      'User-Agent' => "Dropio Ruby Library v1.0",
      'Accept' => 'application/json'
    }
    @@http_header
  end
  
  # Starts and completes the given request. Returns or yields the response body.
  def complete_request(request)
    response = Net::HTTP.new(Dropio.api_url).start { |http| http.request(request) }
    
    case response
    when Net::HTTPSuccess then yield response.body if block_given?
    when Net::HTTPBadRequest then raise Dropio::RequestError, parse_error_message(response)
    when Net::HTTPForbidden then raise Dropio::AuthorizationError, parse_error_message(response)
    when Net::HTTPNotFound then raise Dropio::MissingResourceError, parse_error_message(response)
    when Net::HTTPServerError then raise Dropio::ServerError, "There was a problem connecting to Drop.io."
    end
    
    response.body
  end
  
  # Extracts the error message from the response for the exception.
  def parse_error_message(response)
    error_hash = JSON.parse(response.body) rescue nil
    
    if (error_hash && error_hash.is_a?(Hash) && error_hash[:response] && error_hash[:response][:message])
      return error_hash[:response][:message]
    else
      return "There was a problem connecting to Drop.io."
    end
  end
  
end

dir = File.dirname(__FILE__)
$:.unshift dir unless $:.include?(dir)

require 'client/base.rb'
require 'client/mapper.rb'