dir = File.dirname(__FILE__)
$:.unshift dir unless $:.include?(dir)

module Dropio
  class << self; attr_accessor :api_key, :base_url, :api_url end
end

Dropio.base_url = "http://drop.io"
Dropio.api_url = "http://api.drop.io"

require 'net/http'
require 'uri'
require 'singleton'
require 'rubygems'
require 'json'
require 'dropio/core'
require 'dropio/client'
require 'dropio/drop'
require 'dropio/asset'
require 'dropio/comment'
