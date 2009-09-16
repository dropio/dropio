module Dropio
  VERSION = '1.0.0'
  
  class MissingResourceError < Exception; end
  class AuthorizationError < Exception; end
  class RequestError < Exception; end
  class ServerError < Exception; end
  
  class Config
    class << self
      attr_accessor :api_key, :base_url, :api_url, :upload_url, :version
    end
  end
  
end

require 'rubygems'
require 'rbconfig'
require 'mime/types'
require 'httparty'
require 'net/http/post/multipart'

Dropio::Config.base_url = "http://drop.io"
Dropio::Config.api_url = "http://api.drop.io"
Dropio::Config.upload_url = "http://assets.drop.io/upload"
Dropio::Config.version = "2.0"

require 'dropio/api'
require 'dropio/client'
require 'dropio/resource'
require 'dropio/drop'
require 'dropio/asset'
require 'dropio/comment'
require 'dropio/subscription'
