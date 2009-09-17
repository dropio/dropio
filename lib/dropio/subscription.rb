class Dropio::Subscription < Dropio::Resource
  attr_accessor :id, :username, :message, :type
  
  # Fetches a single Subscription
  def self.find(id)
    Dropio::Resource.client.subscription(id)
  end
  
  # Destroys the given subscription. Admin +token+ required
  def destroy!(token)
    Dropio::Resource.client.delete_subscription(self,token)
    nil
  end
  
end