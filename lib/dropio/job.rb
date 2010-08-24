class Dropio::Job < Dropio::Resource
  
  attr_accessor :id, :job_type, :using, :inputs, :outputs, :pingback_url
  
  # Finds a job for a drop and asset
  def self.find(id,drop_name,asset_name_or_id, token=nil)
    Dropio::Resource.client.job(id, drop_name, asset_name_or_id, token)
  end

  # Creates a job
  def self.create(job_type,using,inputs,outputs,pingback_url=nil)
    Dropio::Resource.client.create_job({
      :job_type => job_type,
      :using => using,
      :inputs => inputs,
      :outputs => outputs
    })
  end
 
  
end