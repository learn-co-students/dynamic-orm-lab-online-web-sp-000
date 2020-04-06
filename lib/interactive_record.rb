# binding.pry
require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize 
  end
  
  def self.selecting
    sql = "SELECT * FROM #{table_name}"
  end
  
  def self.column_names
    sql = "PRAGMA table_info(#{table_name})"
    DB[:conn].execute(sql).map{|col| col["name"]}
  end
  
  def self.values
    binding.pry
    sql = "PRAGMA table_info(#{table_name})"
    DB[:conn].execute(sql).map{|val| val["value"]}
  end 
  
  def initialize(columns={})
    columns.each{|col, value| self.send("#{col}=", value)}
  end
  
  def table_name_for_insert
    self.class.table_name 
  end 
  
  def col_names_for_insert
    arr = self.class.column_names
    arr.slice(1, arr.length).join(", ")
  end 
  
  def values_for_insert
    attributes = self.class.column_names.map{|col| self.send(col).to_s}.filter{|c| c.length > 0}
    attributes.map{|val| "\'#{val}\'"}.join(", ") 
  end 
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id ||= DB[:conn].execute("SELECT last_insert_rowid()")[0]["last_insert_rowid()"]
  end 
  
  def self.find_by_name(name)
    sql = "#{selecting} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end 
  
  def self.find_by(attribute)
    #binding.pry
    sql = attribute.map{|key, value| "#{selecting} WHERE #{key} = \'#{value}\'"}[0]
    DB[:conn].execute(sql)
  end 
  
end