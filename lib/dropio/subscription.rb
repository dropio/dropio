class Dropio::Subscription < Dropio::Resource
  attr_accessor :id, :username, :message, :type, :drop
  
  # Destroys the given subscription
  def destroy!
    Dropio::Resource.client.delete_subscription(self)
    nil
  end
  
end