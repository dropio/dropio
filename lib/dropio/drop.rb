class Dropio::Drop < Dropio::Resource
  
  attr_accessor :name, :email, :guest_token, :description, :expires_at, :expiration_length, 
                :max_bytes, :current_bytes, :asset_count, :chat_password, :password, 
                :admin_password, :admin_email, :email_key
     
  # Gets the default token to be used, prefers the admin token.           
  def default_token
    self.guest_token
  end
  
  # Gets a list of assets associated with the Drop. Paginated at 
  def assets(page = 1, order = :oldest)
    Dropio::Resource.client.assets(self, page, order)
  end
  
  # Finds a drop with +name+ and optional authorization +token+
  def self.find(name, token = nil)
    Dropio::Resource.client.drop(name, token)
  end
  
  # Finds all the drops associated with a manager account.
  def self.find_manager_drops(manager_api_token, page = 1)
    Dropio::Resource.client.manager_drops(manager_api_token, page)
  end
  
  # Creates a drop with an +attributes+ hash.
  # Valid attributes: name (string), expiration_length (string), password (string), and admin_password (string)
  # Descriptions can be found here: http://groups.google.com/group/dropio-api/web/full-api-documentation
  def self.create(attributes = {})
    Dropio::Resource.client.create_drop(attributes)
  end
  
  # Changes the name of a drop.
  def change_name(new_name)
    Dropio::Resource.client.change_drop_name(self,new_name)
  end
  
  # Gets the drop's embeddable uploader code
  def upload_code
    Dropio::Resource.client.drop_upload_code(self)
  end
  
  # Empties the drop, including it's assets.
  def empty
    Dropio::Resource.client.empty_drop(self)
  end
  
  # Promotes a nickname in the drop chat to admin.
  def promote(nick)
    Dropio::Resource.client.promote_nick(self,nick)
  end
  
  # Saves the Drop.
  def save
    Dropio::Resource.client.update_drop(self)
  end
  
  # Deletes the Drop from the system including all associated assets.
  def destroy!
    Dropio::Resource.client.delete_drop(self)
  end
  
  # Adds a file to the Drop from a given +url+
  def add_file_from_url(url, description = nil, convert_to = nil, pingback_url = nil)
    Dropio::Resource.client.add_file_from_url(self,url,description, convert_to, pingback_url)
  end
  
  # Adds a file to the Drop given the +file_path+.
  def add_file(file_path, description = nil, convert_to = nil, pingback_url = nil)
    Dropio::Resource.client.add_file(self, file_path, description, convert_to, pingback_url)
  end
  
  # Creates a note with a +title+ and +contents+
  def create_note(contents, title = nil, description = nil)
    Dropio::Resource.client.create_note(self, contents, title, description)
  end
  
  # Creates a link with a +url+, +title+, and +description+.
  def create_link(url, title = nil, description = nil)
    Dropio::Resource.client.create_link(self, url, title, description)
  end
  
  # Creates a subscription to receive POSTs from drop.io.
  def create_pingback_subscription(url, events = {})
    Dropio::Resource.client.create_pingback_subscription(self,url,events)
  end
  
  # Gets a list of Subscription objects.
  def subscriptions(page = 1)
    Dropio::Resource.client.subscriptions(self, page)
  end
  
  # Generates an authenticated URL that will bypass any login action.
  def generate_url
    Dropio::Resource.client.generate_drop_url(self)
  end
  
end