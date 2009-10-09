class Dropio::Subscription < Dropio::Resource
  attr_accessor :id, :username, :message, :type, :drop
  
  # Destroys the given subscription. Admin +token+ required
  def destroy!(token)
    Dropio::Resource.client.delete_subscription(self,token)
    nil
  end
  
end