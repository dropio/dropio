class Dropio::Subscription < Dropio::Resource
  attr_accessor :id, :username, :message
  
  # Fetches a single Subscription
  def self.find(id)
    self.client.find_subscription(id)
  end
  
  # Destroys the given subscription. Admin +token+ required
  def destroy!(token)
    self.client.destroy_subscription(self,token)
    nil
  end
  
end