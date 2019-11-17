require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  #class needed to use the attr_accessors specific to this class and make as columns
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
end
