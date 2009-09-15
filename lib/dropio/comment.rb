class Dropio::Comment < Dropio::Resource
  
  attr_accessor :id, :contents, :created_at, :asset
  
  # Saves the comment back to drop.io
  def save
    self.client.save_comment(self)
  end
  
  # Destroys the comment on drop.io.  Don't try to use an Comment after destroying it.
  def destroy
    self.client.destroy_comment(self)
  end
  
end