require 'dropio/version'

module Dropio
  class Error < StandardError; end
  
  class MissingResourceError < Error; end
  class AuthorizationError   < Error; end
  class RequestError         < Error; end
  class ServerError          < Error; end
  
  class Config
    class << self
      attr_accessor :api_key, :base_url, :api_url, :upload_url, :version, :debug, :timeout
    end
  end
  
end

Dropio::Config.base_url   = "http://drop.io"
Dropio::Config.api_url    = "http://api.drop.io"
Dropio::Config.upload_url = "http://assets.drop.io/upload"
Dropio::Config.version    = "2.0"
Dropio::Config.debug      = false
Dropio::Config.timeout    = 60 # Default in Ruby

require 'dropio/api'
require 'dropio/client'
require 'dropio/resource'
require 'dropio/drop'
require 'dropio/asset'
require 'dropio/comment'
require 'dropio/subscription'
require 'dropio/job'

