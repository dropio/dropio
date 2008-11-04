class Dropio::Drop < Dropio::Resource
  
  attr_accessor :name, :email, :voicemail, :conference, :fax, :rss, :guest_token,
                :admin_token, :expiration_length, :guests_can_comment, :guests_can_add, :guests_can_delete,
                :max_bytes, :current_bytes, :hidden_upload_url, :upload_url, :password, :admin_password, :premium_code
  
  # Gets a list of assets associated with the Drop. Paginated at 
  def assets(page = 1)
    Dropio::Client.instance.find_assets(self, page)
  end
  
  # Finds a drop with +name+ and optional authorization +token+
  def self.find(name, token = nil)
    Dropio::Client.instance.find_drop(name, token)
  end
  
  # Creates a drop with an +attributes+ hash.
  # Valid attributes: name (string), guests_can_comment (boolean), guests_can_add (boolean), guests_can_delete (boolean), expiration_length (string), password (string), admin_password (string), and premium_code (string)
  # Descriptions can be found here: http://groups.google.com/group/dropio-api/web/full-api-documentation
  def self.create(attributes = {})
    Dropio::Client.instance.create_drop(attributes)
  end
  
  # Saves the Drop.
  def save
    Dropio::Client.instance.save_drop(self)
  end
  
  # Deletes the Drop from the system including all associated assets.
  def destroy
    Dropio::Client.instance.destroy_drop(self)
  end
  
  # Adds a file to the Drop given the +file_path+.
  def add_file(file_path)
    Dropio::Client.instance.add_file(self, file_path)
  end
  
  # Creates a note with a +title+ and +contents+
  def create_note(title,contents)
    Dropio::Client.instance.create_note(self, title, contents)
  end
  
  # Creates a link with a +url+, +title+, and +description+.
  def create_link(url, title = nil, description = nil)
    Dropio::Client.instance.create_link(self, url, title, description)
  end
  
  # Generates an authenticated URL that will bypass any login action.
  def generate_url
    Dropio::Client.instance.generate_drop_url(self)
  end
  
end