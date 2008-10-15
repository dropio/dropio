class Dropio::Client::Mapper
  
  def self.map_drop(response_body)
    return parse_and_map(Dropio::Drop, response_body)
  end
  
  def self.map_asset(response_body)
    return parse_and_map(Dropio::Asset, response_body)
  end
  
  private
  
  def self.parse_and_map(model_class, response_body)
    h = JSON.parse(response_body)
    
    # single asset
    return model_class.new(h) if h.is_a?(Hash)
    
    models = []
    h.each do |model_hash|
      model = Asset.new(model) if model.is_a?(Hash)
      models << model
    end if h.is_a?(Array)
    
    # multiple assets
    return models
  end
  
end