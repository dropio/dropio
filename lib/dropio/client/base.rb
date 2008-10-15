class Dropio::Client

  def find_drop(drop_name, token = nil)
    uri = URI.parse(drop_path(drop_name) + get_request_tokens(token))
    response = Net::HTTP.get_response(uri)
    drop = Mapper.map_drop(response.body)
  end
  
  protected
  
  def get_request_tokens(token = nil)
    "?api_key=#{Dropio.api_key}&token=#{token}&format=json"
  end
  
  def comment_path(drop, asset, comment = nil)
    comment_id = (comment) ? comment.id.to_s : ''
    return asset_path(drop,asset) + "/comments/" + comment_id
  end
  
  def asset_path(drop, asset = nil)
    asset_name = (asset) ? asset.name : ''
    return drop_path(drop) + "/assets/" + asset_name
  end
  
  def drop_path(drop)
    if drop.is_a?(Dropio::Drop)
      drop_name = drop.name
    elsif drop.is_a?(String)
      drop_name = drop
    else
      drop_name = ''
    end
    
    return Dropio.api_url + "/drops/" + drop_name
  end
  
end