require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def initialize(attributes={})
    attributes.each {|property, value| self.send("#{property}=", value)}
  end
  
  def self.table_name
    self.to_s.downcase.pluralize    
  end 
    
  def self.column_names
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = table_info.collect {|row| row["name"]}
    column_names.compact
  end
  
  def table_name_for_insert
    self.class.table_name
  end
    
  def col_names_for_insert
    self.class.column_names[1..-1].join(', ')
    # self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end 
    
  def values_for_insert
    # instance has id, name, grade
    # run through associated column_names and send instance's value to each respective column_name
    # id = nil when initialized bc assigned upon db entry so skip id value, id value = nil
    values = self.class.column_names.collect {|col_name| "'#{send(col_name)}'" unless send(col_name).nil?}
    # remove nil values with compact, join them into a string for SQL to replace ?
    values.compact.join(", ")
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
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    SQL
    
    DB[:conn].execute(sql, name)
  end 
  
  def self.find_by(attribute)
    sql = <<-SQL 
      SELECT * FROM #{self.table_name}
      WHERE #{attribute.flatten[0].to_s} = ?
    SQL
    
    DB[:conn].execute(sql, attribute.flatten[1])
  end 
  
end