require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true #returns results as hash
    sql = "PRAGMA table_info('#{table_name}')"
    
    DB[:conn].execute(sql).map do |column_info|
      column_info["name"]
    end.compact
  end
  
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(', ')
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each do |column_name|
      values << "'#{send(column_name)}'" unless send(column_name).nil? #control for id value 
    end
    values.join(', ')
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = ?
    SQL
    DB[:conn].execute(sql, name)
  end
  
  def self.find_by(option={})
    row = []
    option.each do |property, value|
      if value.is_a? String 
        sql = "SELECT * FROM #{self.table_name} WHERE #{property} = '#{value}'"
      else
        sql = "SELECT * FROM #{self.table_name} WHERE #{property} = #{value}"
      end
      row = DB[:conn].execute(sql)
    end
    row
  end
end