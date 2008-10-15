class Dropio::Comment < Dropio::Model
  
  attr_accessor :id, :contents, :created_at, :asset
  
  def save
    Dropio::Client.instance.save_comment(self)
  end
  
  def destroy
    Dropio::Client.instance.destroy_comment(self)
  end
  
end