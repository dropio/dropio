class Dropio::Asset < Dropio::Resource
  
  attr_accessor :drop, :name, :type, :title, :description, :filesize, :created_at,
                :thumbnail, :status, :file, :converted, :hidden_url, :pages,
                :duration, :artist, :track_title, :height, :width, :contents, :url
  
  # Returns the comments on this asset.  Comments are loaded lazily.  The first
  # call to +comments+ will fetch the comments from the server.  They are then
  # cached until the asset is reloaded.
  def comments
    @comments = Dropio::Client.instance.find_comments(self) if @comments.nil?
    @comments ||= []
  end         
  
  # Adds a comment to the asset with the given +contents+.  Returns the
  # new +Comment+.
  def create_comment(contents)
    Dropio::Client.instance.create_comment(self, contents)
  end
  
  # Saves the asset back to drop.io.
  def save
    Dropio::Client.instance.save_asset(self)
  end
  
  # Destroys the asset on drop.io.  Don't try to use an Asset after destroying it.
  def destroy!
    Dropio::Client.instance.destroy_asset(self)
    nil
  end
  
  # Returns true if the Asset can be faxed.
  def faxable?
    return type == "Document"
  end
  
  # Fax the asset to the given +fax_number+.  Make sure the Asset is +faxable?+
  # first, or +send_to_fax+ will raise an error.
  def send_to_fax(fax_number)
    raise "Can't fax Asset: #{self.inspect} is not faxable" unless faxable?
    Dropio::Client.instance.send_to_fax(self, fax_number)
    nil
  end
  
  # Sends the asset to the given +emails+ with an optional +message+.
  def send_to_emails(emails = [], message = nil)
    Dropio::Client.instance.send_to_emails(self, emails, message)
  end
  
  # Sends the asset to a Drop by +drop_name+
  def send_to_drop(drop_name)
    Dropio::Client.instance.send_to_drop(self, drop_name)
  end
  
  # Generates an authenticated URL that will bypass any login action.
  def generate_url
    Dropio::Client.instance.generate_asset_url(self)
  end
  
end