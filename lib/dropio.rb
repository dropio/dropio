module Dropio
  VERSION = '3.0.0'
  
  class MissingResourceError < Exception; end
  class AuthorizationError < Exception; end
  class RequestError < Exception; end
  class ServerError < Exception; end
  
  class Config
    class << self
      attr_accessor :api_key, :api_secret, :base_url, :api_url, :upload_url, :version, :debug, :timeout
    end
  end
  
end

require 'rbconfig'
require 'mime/types'
require 'httparty'
require 'net/http/post/multipart'

Dropio::Config.base_url = "http://drop.io"
Dropio::Config.api_url = "http://api.drop.io"
Dropio::Config.upload_url = "http://assets.drop.io/upload"
Dropio::Config.version = "3.0"
Dropio::Config.debug = false
Dropio::Config.timeout = 60 # Default in Ruby

require 'dropio/api'
require 'dropio/client'
require 'dropio/resource'
require 'dropio/drop'
require 'dropio/asset'
require 'dropio/comment'
require 'dropio/subscription'
