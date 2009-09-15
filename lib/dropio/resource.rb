class Dropio::Resource
  
  def initialize(params = {})
    params.each do |key,val|
      self.send("#{key}=", val) if self.respond_to? key
    end
  end

  def self.client
    @@client ||= Dropio::Client.new
  end
  
end