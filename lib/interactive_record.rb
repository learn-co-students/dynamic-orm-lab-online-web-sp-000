require_relative "../config/environment.rb"
require 'active_support/inflector'


class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    
    table_info = DB[:conn].execute(sql)
    table_info.collect {|table_column| table_column["name"]}.compact
  end
  
  def initialize(attributes = {})
    attributes.each {|key, value| self.send("#{key}=", value)}
  end
  
  def table_name_for_insert 
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
  end
  
  def values_for_insert
    values = self.class.column_names.collect do |col_name| 
      "'#{self.send(col_name)}'" unless self.send(col_name).nil?
    end
    
    values.compact.join(", ")
  end
  
  def values_for_insert_skip_wierd_format
    # Due to the difference in how the values are inserted into the database (directly vs. with bound parameters), calling values_for_insert.split(", ") won't work.
    
    # That would cause a Student to have these values: 
    # [{"id"=>1, "name"=>"'Sam'", "grade"=>"'11'", 0=>1, 1=>"'Sam'", 2=>"'11'"}]
    # instead of these values: 
    # [{"id"=>1, "name"=>"Sam", "grade"=>11, 0=>1, 1=>"Sam", 2=>11}]. Tricky bug!!!
    
    self.class.column_names.collect {|col_name| self.send(col_name)}.compact
  end
  
  
  def save
    # This is based on the code from the video "Building a Metaprogrammed Abstract ORM"
    
    sql = <<-SQL 
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) 
      VALUES (#{question_marks_for_insert})
    SQL
    
    DB[:conn].execute(sql, values_for_insert_skip_wierd_format)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def question_marks_for_insert
    self.class.column_names[1..-1].size.times.collect{"?"}.join(", ")
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name)
  end
  
  def self.find_by(attribute_hash)
   
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{attribute_hash.keys.first} = ?
    SQL
    
    DB[:conn].execute(sql, attribute_hash.values.first)
    end
end
      

        
    
   
