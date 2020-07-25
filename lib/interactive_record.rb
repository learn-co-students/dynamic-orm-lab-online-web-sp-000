require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    col_names = []
    sql = "PRAGMA table_info('#{self.table_name}')"
    pragma = DB[:conn].execute(sql)
    pragma.each do |hash|
      col_names << hash["name"]
    end
    
    col_names.compact
   
  end
  
  def initialize(options = {})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end
  
  def table_name_for_insert
  end

end



