dir = File.dirname(__FILE__)
$:.unshift dir unless $:.include?(dir)

module Dropio
  class << self
    attr_accessor :api_key, :base_url, :api_url, :upload_url
  end
end

Dropio.base_url = "http://drop.io"
Dropio.api_url = "http://api.drop.io"
Dropio.upload_url = "http://assets.drop.io/upload"

require 'net/http'
require 'uri'
require 'singleton'
require 'rubygems'
require 'mime/types'
require 'base64'
require 'cgi'
require 'json'
require 'digest/sha1'
require 'dropio/errors'
require 'dropio/client'
require 'dropio/resource'
require 'dropio/drop'
require 'dropio/asset'
require 'dropio/comment'


