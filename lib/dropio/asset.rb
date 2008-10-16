class Dropio::Asset < Dropio::Resource
  
  attr_accessor :drop, :name, :type, :title, :description, :filesize, :created_at,
                :thumbnail, :status, :file, :converted, :hidden_url, :pages,
                :duration, :artist, :track_title, :height, :width, :contents, :url
                
  def comments
    @comments = Dropio::Client.instance.find_comments(self) if @comments.nil?
    @comments ||= []
  end         
  
  def self.find(drop, name)
    Dropio::Client.instance.find_asset(drop, name)
  end
  
  def create_comment(contents)
    Dropio::Client.instance.create_comment(self, contents)
  end
  
  def save
    Dropio::Client.instance.save_asset(self)
  end
  
  def destroy
    Dropio::Client.instance.destroy_asset(self)
  end
  
  def faxable?
    return type == "Document"
  end
                
  def send_to_fax(fax_number)
    Dropio::Client.instance.send_to_fax(fax_number)
  end
  
  def send_to_emails(emails = [], message = nil)
    Dropio::Client.instance.send_to_email(emails, message)
  end
  
  def send_to_drop(drop_name)
    Dropio::Client.instance.send_to_drop(drop_name)
  end
  
end