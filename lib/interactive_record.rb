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
    
    table_info = DB[:conn].execute(sql)
    column_names = Array.new
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end
  
  def initialize(options={})
    options.each do |attritube, value|
      self.send("#{attritube}=", value)
    end
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names[1..-1].join(", ")
  end
  
  def values_for_insert
    values = Array.new
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" if !send(col_name).nil?
    end
    values.join(", ")
  end
  
  def save
    sql = <<-SQL 
      INSERT INTO #{table_name_for_insert} 
      (#{col_names_for_insert}) 
      VALUES (#{values_for_insert})
    SQL
    
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end
  
  def self.find_by(attritube_hash)
    col_name = attritube_hash.keys[0].to_s
    value = attritube_hash.values[0]
    sql = "SELECT * FROM #{table_name} WHERE #{col_name} = ?"
    DB[:conn].execute(sql, value)
  end
end