require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end 
  
  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    DB[:conn].execute(sql).collect {|col| col["name"]}
  end
  
  def initialize(options = {})
    options.each {|key, value| self.send("#{key}=", value)} unless options == nil
  end
  
  def table_name_for_insert 
    self.class.table_name
  end
  
  def col_names_for_insert 
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end 
  
  def values_for_insert 
    col_names_for_insert.split(", ").collect {|col| "'#{send(col)}'"}.join(", ")
  end 
  
  def save 
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = ?
    SQL
    
    DB[:conn].execute(sql, name)
  end 
  
  def self.find_by(hash)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE #{hash.keys.first} = ?
    SQL
    
    DB[:conn].execute(sql, hash.values)
  end  
end