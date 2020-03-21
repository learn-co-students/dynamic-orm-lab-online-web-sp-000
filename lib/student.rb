require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
self.column_names.each do |col_nam|
    attr_accessor col_nam.to_sym
  end
end
