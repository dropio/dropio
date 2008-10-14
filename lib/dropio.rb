dir = File.dirname(__FILE__)
$:.unshift dir unless $:.include?(dir)

module Dropio
  class << self; attr_accessor :api_key end
end

require 'dropio/drop'
require 'dropio/asset'