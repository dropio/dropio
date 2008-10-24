class Dropio::Drop < Dropio::Resource
  
  attr_accessor :name, :email, :voicemail, :conference, :fax, :rss, :guest_token,
                :admin_token, :expiration_length, :guests_can_comment, :guests_can_add, :guests_can_delete,
                :max_bytes, :current_bytes, :hidden_upload_url, :upload_url
  
  def assets
    @assets = Dropio::Client.instance.find_assets(self) if @assets.nil?
    @assets ||= []
  end
  
  def self.find(name, token = nil)
    Dropio::Client.instance.find_drop(name, token)
  end
  
  def self.create(attributes = {})
    Dropio::Client.instance.create_drop(attributes)
  end
  
  def save
    Dropio::Client.instance.save_drop(self)
  end
  
  def destroy
    Dropio::Client.instance.destroy_drop(self)
  end
  
  def add_file(file)
    Dropio::Client.instance.add_file(self, file)
  end
  
  def create_note(title,contents)
    Dropio::Client.instance.create_note(self, title, contents)
  end
  
  def create_link(url, title = nil, description = nil)
    Dropio::Client.instance.create_link(self, url, title, description)
  end
  
end