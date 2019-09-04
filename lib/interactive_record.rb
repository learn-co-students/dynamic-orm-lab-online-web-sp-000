require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def initialize(options={})
    options.each do |property, value|
    self.send("#{property}=", value)
  end 
  end 
end