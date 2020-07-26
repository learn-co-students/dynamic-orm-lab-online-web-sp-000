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
    "#{self.class.table_name}"
  end
  
  def col_names_for_insert
    self.class.column_names.reject{|col| col == "id"}.join(", ")
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
    values << "'#{send(col_name)}'" unless send(col_name).nil? 
    end
    values.join(", ")
  end
  
  def save
    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?", name)
  end
  
  def self.find_by(attribute)
    attribute_key = attribute.keys.join
    attribute_value = attribute.values.join
    DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{attribute_key} = ?", attribute_value)
  end

end



