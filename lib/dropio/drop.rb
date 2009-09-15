class Dropio::Drop < Dropio::Resource
  
  attr_accessor :name, :email, :voicemail, :conference, :fax, :rss, :guest_token, :description,
                :admin_token, :expires_at, :expiration_length, :guests_can_comment, :guests_can_add, :guests_can_delete,
                :max_bytes, :current_bytes, :hidden_upload_url, :asset_count, :chat_passowrd, :default_view, :upload_url, 
                :password, :admin_password, :premium_code
     
  # Gets the default token to be used, prefers the admin token.           
  def default_token
    self.admin_token || self.guest_token
  end
  
  # Gets a list of assets associated with the Drop. Paginated at 
  def assets(page = 1)
    Resource.client.assets(self, page)
  end
  
  # Finds a drop with +name+ and optional authorization +token+
  def self.find(name, token = nil)
    Resource.client.drop(name, token)
  end
  
  # Creates a drop with an +attributes+ hash.
  # Valid attributes: name (string), default_view (string), guests_can_comment (boolean), guests_can_add (boolean), guests_can_delete (boolean), expiration_length (string), password (string), admin_password (string), and premium_code (string)
  # Descriptions can be found here: http://groups.google.com/group/dropio-api/web/full-api-documentation
  def self.create(attributes = {})
    Resource.client.create_drop(attributes)
  end
  
  # Gets the drop's embeddable uploader code
  def upload_code
    Resource.client.drop_upload_code(self)
  end
  
  # Empties the drop, including it's assets.
  def empty
    Resource.client.empty_drop(self)
  end
  
  # Promotes a nickname in the drop chat to admin.
  def promote(nick)
    Resource.client.promote_nick(nick)
  end
  
  # Saves the Drop.
  def save
    Resource.client.save_drop(self)
  end
  
  # Deletes the Drop from the system including all associated assets.
  def destroy
    Resource.client.delete_drop(self)
  end
  
  def add_from_from_url(url)
    Resource.client.add_from_from_url(self,url)
  end
  
  # Adds a file to the Drop given the +file_path+.
  def add_file(file_path)
    Resource.client.add_file(self, file_path)
  end
  
  # Creates a note with a +title+ and +contents+
  def create_note(title,contents)
    Resource.client.create_note(self, title, contents)
  end
  
  # Creates a link with a +url+, +title+, and +description+.
  def create_link(url, title = nil, description = nil)
    Resource.client.create_link(self, url, title, description)
  end
  
  # Creates a Twitter Subscription
  def create_twitter_subscription(username,password)
    Resource.client.create_twitter_subscription(self,username,password)
  end
  
  # Creates an email Subscription
  def create_email_subscription(email)
    Resource.client.create_email_subscription(self,email)
  end
  
  # Gets a list of Subscription objects.
  def subscriptions
    Resource.client.subscriptions(self)
  end
  
  # Generates an authenticated URL that will bypass any login action.
  def generate_url
    Resource.client.generate_drop_url(self)
  end
  
end