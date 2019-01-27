require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  column_names.each { |n| attr_accessor n.to_sym }
end
