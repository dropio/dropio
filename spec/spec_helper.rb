require 'rubygems'
require 'spec'

lib_dir = File.dirname(__FILE__) + '/../lib'
$:.unshift lib_dir unless $:.include?(lib_dir)

require 'dropio'
include Dropio

module Enumerable
  # Apply an expectation to each object in the collection.
  def each_should(*args)
    each {|item| item.should(*args)}
  end
  
  # Apply a negative expectation to each object in the collection.
  def each_should_not(*args)
    each {|item| item.should_not(*args)}
  end
end

# Make class mocks and stubs pretend to belong to their given class.
module Spec::Mocks
  class Mock
    def is_a?(klass)
      if @name.is_a?(Class) and @name <= klass
        true
      else
        super
      end
    end
  end
end
