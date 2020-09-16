require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'
class Student < InteractiveRecord
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
        #this is always going to be confusing. do you consider this space an instance or a class thing? 
        #i mean its inside the class but each instnace has its own unique attriute values so u can't quite guess
        #so it's a bit arbitrary
    
end
