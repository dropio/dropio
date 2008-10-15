class Dropio::Client
  include Singleton
end

dir = File.dirname(__FILE__)
$:.unshift dir unless $:.include?(dir)

require 'client/base.rb'
require 'client/mapper.rb'