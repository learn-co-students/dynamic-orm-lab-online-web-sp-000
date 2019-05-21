require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def initialize(options={})
    options.each{ |key, value| self.send("#{key}=", value) }
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if{ |name| name == "id" }.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def values_for_insert
    values = []
    
    self.class.column_names.each do |name|
      values << "'#{send(name)}'" unless send(name).nil?
    end
    values.join(", ")
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    table_data = DB[:conn].execute(sql)
    column_names = []
    
    table_data.each do |column|
      column_names << column["name"]
    end
    
    column_names
  end
  
  def self.find_by(hash)
    name = hash.keys[0]
    value = hash[name]
    sql = "SELECT * FROM #{self.table_name} WHERE #{name.to_s} = ?"
    DB[:conn].execute(sql, value)
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
 
end
