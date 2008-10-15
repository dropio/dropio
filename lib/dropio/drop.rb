class Dropio::Drop
  include Dropio::Model
  attr_accessor :name, :email, :voicemail, :conference, :fax, :rss, :user_token,
                :admin_token, :expiration_length, :privacy_type, :delete_permission_type, 
                :max_bytes, :current_bytes, :hidden_upload_url, :upload_url
  
  def self.find(name, token = nil)
    Dropio::Client.instance.find_drop(name, token)
  end
  
end