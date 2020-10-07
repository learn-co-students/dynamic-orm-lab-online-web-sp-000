require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true 
    
    sql = "pragma table_info('#{table_name}')"
    
    table_info =  DB[:conn].execute(sql)
    column_names = []
    table_info.each {|row| column_names << row["name"]}
    column_names.compact
  end
  
  def initialize(students={})
    students.each  {|k, v| self.send("#{k}=", v)}
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if {|column| column == "id"}.join(", ")
  end
  
  def values_for_insert
    val = []
    self.class.column_names.each do |col| 
      val << "'#{send(col)}'" unless send(col).nil?
    end
    val.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end
  
  def self.find_by(attribute_hash)
    attribute_name = attribute_hash.keys.join
    attribute_value = attribute_hash.values[0]
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_name} = '#{attribute_value}'"
    DB[:conn].execute(sql)
  end
  
end