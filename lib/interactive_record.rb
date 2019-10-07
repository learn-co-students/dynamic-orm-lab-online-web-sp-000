require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true
    
    sql = "PRAGMA table_info (#{self.table_name})"
    table_info = DB[:conn].execute(sql)
    column = []
    
    table_info.each do |hash|
      column << hash["name"]
    end
    column.compact
  end
  
  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    array = self.class.column_names
    array.delete("id")
    array.join(", ")
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each do |attribute|
      values << "'#{self.send(attribute)}'" unless self.send(attribute).nil?
    end
    values.join(', ')
  end
    
  def save
    save = "
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})
      "
    DB[:conn].execute(save)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]   #is there a way to abstract self.id? surely there is, can there be cases where self.id does not exist?
  end
  
  def self.find_by_name(name)
    find = "
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    "
    DB[:conn].execute(find, name)
  end
  
  def self.find_by(attribute = {})
    attribute_name_for_insert = nil
    attribute_value_for_insert = nil
    attribute.each do |key, value|
      attribute_name_for_insert = key.to_s.downcase
      attribute_value_for_insert = value
    end
    
    find_by = "
    SELECT * FROM #{table_name}
    WHERE #{attribute_name_for_insert} = '#{attribute_value_for_insert}'
    "
    DB[:conn].execute(find_by)
  end
      
  
end