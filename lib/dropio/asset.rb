class Dropio::Asset < Dropio::Resource
  
  attr_accessor :id, :drop, :name, :type, :title, :description, :filesize, :created_at, :status, 
                :pages, :duration, :artist, :track_title, :height, :width, :contents, :url,
                :roles, :locations
     
  # Finds a particular Asset by drop and asset name.
  def self.find(drop, id)
    Dropio::Resource.client.asset(drop, id)
  end
  
  # Changes the name of an asset.
  def change_name(new_name)
    Dropio::Resource.client.change_asset_name(self,new_name)
  end
  
  # Gets the Assets's embed code
  def embed_code
    Dropio::Resource.client.asset_embed_code(self)
  end       
  
  # Saves the Asset back to drop.io.
  def save
    Dropio::Resource.client.update_asset(self)
  end
  
  # Destroys the Asset on drop.io.  Don't try to use an Asset after destroying it.
  def destroy!
    Dropio::Resource.client.delete_asset(self)
    return nil
  end
  
  # Destroys the given role on an Asset
  def destroy_role!(role)
    Dropio::Resource.client.delete_role(self, role)
    return nil
  end
  
  # Destroys the given role at the specified location on an Asset
  def destroy_location!(role, location)
    Dropio::Resource.client.delete_role(self, role, location)
    return nil
  end
  
  # Copies the Asset to the given drop.
  def copy_to(target_drop)
    Dropio::Resource.client.copy_asset(self, target_drop)
  end
  
  # Moves the Asset to the given drop.
  def move_to(target_drop)
    Dropio::Resource.client.move_asset(self, target_drop)
  end
  
  # Sends the Asset to a Drop by +drop_name+
  def send_to_drop(drop)
    Dropio::Resource.client.copy_asset(self, drop)
  end
  
  # Generates an authenticated URL that will bypass any login action.
  def generate_url
    Dropio::Resource.client.generate_asset_url(self)
  end
  
  # Generates a url if there's access to the original file.
  def original_file_url(time_to_live = 600)
    Dropio::Resource.client.generate_original_file_url(self)
  end
  
end