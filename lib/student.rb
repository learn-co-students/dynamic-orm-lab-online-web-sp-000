require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  
  self.column_names.each { |cn| attr_accessor cn.to_sym }

end
