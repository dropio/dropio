class Dropio::Resource
  
  def initialize(params = {})
    params.each do |key,val|
      self.send("#{key}=", val) if self.respond_to? key
    end
  end
  
end