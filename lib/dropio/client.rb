class Dropio::Client
  include Singleton
  
  protected
  
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

dir = File.dirname(__FILE__)
$:.unshift dir unless $:.include?(dir)

require 'client/base.rb'
require 'client/mapper.rb'