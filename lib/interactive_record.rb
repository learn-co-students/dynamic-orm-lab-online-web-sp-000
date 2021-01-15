require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase+'s' 
    # binding.pry
  end

  def self.column_names
    DB[:conn].execute("PRAGMA table_info(#{self.table_name})").map{|col_name| col_name['name']}
    # binding.pry
  end
  
  def initialize(attributes={})
    # binding.pry
    attributes.each do |property, value|
      self.send("#{property}=", value)
    end
  end
  
  def table_name_for_insert
    self.class.table_name 
  end
  
  def col_names_for_insert
    self.class.column_names.map do |x|
      x unless x == 'id'
    end.compact.join(', ')
    
  end
  
  def values_for_insert
    # binding.pry
    self.class.column_names.map do |column_name| 
      "'#{send(column_name)}'" unless send(column_name).nil?
    end.compact.join(', ')
  end
  
  def values_for_insert_2
    # binding.pry
    self.class.column_names.map do |column_name| 
      "#{send(column_name)}" unless send(column_name).nil?
    end.compact
  end
  
  def save
    # binding.pry
    save_game = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (?, ?) 
    SQL
    
    DB[:conn].execute(save_game, values_for_insert_2.map{|value| value })
    @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
  
    # if self.class.column_names.include?('id'), playing with code
    # values_for_insert.map{|x| x}
    # (#{values_for_insert})
  end
  
  def self.find_by_name(name)
    # binding.pry 
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)
  end
  
  def self.find_by(attribute)
    # binding.pry
    attribute.map do |key, value|
      DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{key.to_s} = ?", value)
    end[0]
  end
  
    
end