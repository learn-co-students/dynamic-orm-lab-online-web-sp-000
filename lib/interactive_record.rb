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
    col_names = []
    table_info.each do |row|
      col_names << row["name"]
    end 
    col_names.compact
  end 
  
  def initialize(options = {})
    options.each do |prop, val|
      self.send("#{prop}=", val)
    end 
  end 
  
  def table_name_for_insert
    self.class.table_name
  end 
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end 
  
  def values_for_insert
    values = []
    
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
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
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)
  end 
  
  def self.find_by(attr)
    attr_key = attr.keys.join
    attr_val = attr.values.join
    
    sql = "SELECT * FROM #{self.table_name} WHERE #{attr_key} = '#{attr_val}' LIMIT 1"
    row = DB[:conn].execute(sql)
  end 
  
end









