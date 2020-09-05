require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

# The only code the this class needs to contain is 
# the code to create the attr_accessors SPECIFIC TO ITSELF.

class Student < InteractiveRecord

    self.column_names.each do |col_name|
        attr_accessor col_name.to_sym
    end

end
