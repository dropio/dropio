require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

require 'spec'
require 'spec/test/unit'
require 'fakeweb'

FakeWeb.allow_net_connect = false

$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

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
    def kind_of?(klass)
      if @name.kind_of?(Class) and @name <= klass
        true
      else
        super
      end
    end
    alias is_a? kind_of?
  end
end

# Reimplement Module#=== in Ruby.  Without this, === bypasses message
# dispatch, so the trick above doesn't wouldn't apply to case statements.
class Module
  def ===(arg)
    arg.kind_of?(self)
  end
end
