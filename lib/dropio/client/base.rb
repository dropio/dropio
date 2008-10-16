class Dropio::Client

  def find_drop(drop_name, token = nil)
    uri = URI::HTTP.build({:path => drop_path(drop_name), :query => get_request_tokens(token)})
    req = Net::HTTP::Get.new(uri.request_uri, default_header)
    complete_request(req) { |body| Mapper.map_drops(body) }
  end
  
  def find_assets(drop)
    token = (drop.admin_token) ? drop.admin_token : drop.user_token
    uri = URI::HTTP.build({:path => asset_path(drop), :query => get_request_tokens(token)})
    req = Net::HTTP::Get.new(uri.request_uri, default_header)
    complete_request(req) { |body| Mapper.map_assets(drop, body) }
  end
  
  def find_comments(asset)
    drop = asset.drop
    token = (drop.admin_token) ? drop.admin_token : drop.user_token
    uri = URI::HTTP.build({:path => comment_path(drop, asset), :query => get_request_tokens(token)})
    req = Net::HTTP::Get.new(uri.request_uri, default_header)
    complete_request(req) { |body| Mapper.map_comments(asset, body) }
  end
  
  protected
  
  def get_request_tokens(token = nil)
    "api_key=#{Dropio.api_key}&token=#{token}&format=json"
  end

end