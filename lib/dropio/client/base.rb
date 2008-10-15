class Dropio::Client

  def find_drop(drop_name, token = nil)
    uri = URI.parse(drop_path(drop_name) + get_request_tokens(token))
    response = Net::HTTP.get_response(uri)
    Mapper.map_drops(response.body)
  end
  
  def find_assets(drop)
    token = (drop.admin_token) ? drop.admin_token : drop.user_token
    uri = URI.parse(asset_path(drop) + get_request_tokens(token))
    response = Net::HTTP.get_response(uri)
    Mapper.map_assets(drop, response.body)
  end
  
  def find_comments(asset)
    drop = asset.drop
    token = (drop.admin_token) ? drop.admin_token : drop.user_token
    uri = URI.parse(comment_path(drop, asset) + get_request_tokens(token))
    response = Net::HTTP.get_response(uri)
    Mapper.map_comments(asset, response.body)
  end
  
  protected
  
  def get_request_tokens(token = nil)
    "?api_key=#{Dropio.api_key}&token=#{token}&format=json"
  end

end