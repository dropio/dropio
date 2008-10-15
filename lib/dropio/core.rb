module Dropio::Model
  
  def initialize(params = {})
    params.each do |key,val|
      self.send("#{key}=", val) if self.respond_to? key
    end
    self.send(:init) if self.respond_to? :init
  end
  
end