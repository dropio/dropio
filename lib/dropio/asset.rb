class Dropio::Asset < Dropio::Resource
  
  attr_accessor :id, :drop, :name, :type, :title, :description, :filesize, :created_at,
                :thumbnail, :status, :converted, :hidden_url, :pages, :fax_status,
                :duration, :artist, :track_title, :height, :width, :contents, :url,
                :original_filename, :converted_filename, :can_download_original,
                :large_thumbnail, :roles
     
  # Finds a particular Asset by drop and asset name.
  def self.find(drop, name)
    Dropio::Resource.client.asset(drop,name)
  end
  
  # Changes the name of an asset.
  def change_name(new_name)
    Dropio::Resource.client.change_asset_name(self,new_name)
  end
  
  # Returns the comments on this Asset.  Comments are loaded lazily.  The first
  # call to +comments+ will fetch the comments from the server.  They are then
  # cached until the Asset is reloaded.
  def comments(page = 1)
    @comments = Dropio::Resource.client.comments(self, page)
  end
  
  # Gets the Assets's embed code
  def embed_code
    Dropio::Resource.client.asset_embed_code(self)
  end       
  
  # Adds a comment to the Asset with the given +contents+.  Returns the
  # new +Comment+.
  def create_comment(contents)
    Dropio::Resource.client.create_comment(self, contents)
  end
  
  # Saves the Asset back to drop.io.
  def save
    Dropio::Resource.client.update_asset(self)
  end
  
  # Destroys the Asset on drop.io.  Don't try to use an Asset after destroying it.
  def destroy!
    Dropio::Resource.client.delete_asset(self)
    nil
  end
  
  # Copies the Asset to the given drop. The +token+ is the target drop's token if required to add files.
  def copy_to(target_drop)
    Dropio::Resource.client.copy_asset(self, target_drop)
  end
  
  # Moves the Asset to the given drop. The +token+ is the target drop's token if required to add files.
  def move_to(target_drop)
    Dropio::Resource.client.move_asset(self, target_drop)
  end
  
  # Returns true if the Asset can be faxed.
  def faxable?
    return type.downcase == "document"
  end
  
  # Fax the Asset to the given +fax_number+.  Make sure the Asset is +faxable?+
  # first, or +send_to_fax+ will raise an error.
  def send_to_fax(fax_number)
    raise "Can't fax Asset: #{self.inspect} is not faxable" unless faxable?
    Dropio::Resource.client.send_asset_to_fax(self, fax_number)
    nil
  end
  
  # Sends the Asset to the given +emails+ with an optional +message+.
  def send_to_emails(emails = [], message = nil)
    Dropio::Resource.client.send_asset_to_emails(self, emails, message)
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
  def original_file_url
    Dropio::Resource.client.generate_original_file_url(self) if self.can_download_original
  end
  
end