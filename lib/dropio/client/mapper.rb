class Dropio::Client::Mapper
  
  def self.map_drops(response_body)
    return parse_and_map(Dropio::Drop, response_body)
  end
  
  def self.map_assets(drop, response_body)
    assets = parse_and_map(Dropio::Asset, response_body)
    
    assets.drop = drop if assets.is_a?(Dropio::Asset)
    assets.each{ |a| a.drop = drop } if assets.is_a?(Array)
    
    return assets
  end
  
  def self.map_comments(asset, response_body)
    comments = parse_and_map(Dropio::Comment, response_body)
    
    comments.asset = asset if comments.is_a?(Dropio::Comment)
    comments.each{ |c| c.asset = asset } if comments.is_a?(Array)
    
    return comments
  end
  
  private
  
  def self.parse_and_map(model_class, response_body)
    h = JSON.parse(response_body)
    
    # single model
    return model_class.new(h) if h.is_a?(Hash)
    
    # multiple models
    models = []
    
    h.each do |model_hash|
      if model_hash.is_a?(Hash)
        model = model_class.new(model_hash) 
        models << model
      end
    end if h.is_a?(Array)
    
    return models
    
  end
  
end