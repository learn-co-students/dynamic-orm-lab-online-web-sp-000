require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    "#{self.to_s.downcase}s"
  end
  
  def self.column_names
    
  end
  
  def self.attribute_names_for_insert
    ATTRIBUTES.keys[1.. - 1].collect
  end
  
  def self.attribute_values
end
  
 
  
   def self.column_names

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end
  
  
    def initialize(param_names={})
    param_names.each do |property, value|
      self.send("#{property}=", value)
    end
  end
  def table_name_for_insert
    self.class.table_name
  end


  
  def col_names_for_insert
    column_names = []
    self.class.column_names.each do |col| 
        column_names << col
      end
      column_names.delete("id")
     joined_names = column_names.join(", ")
      joined_names
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
   INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

def insert 
  sql = <<-SQL
  
  INSERT INTO #{self.class.table_name}(title) VALUES #{self.title}
  
  
  SQL
    DB[:conn].execute(sql, *attribute_values)
    
    self.id = DB[:conn].execute("SELECT last_insert_row_id();").flatten.first
  end
  
  
  def self.find_by(key_value_pair)
  value = key_value_pair.values.first
  value_int = nil  
  
  if value.class == Integer 
   
   value_int = value 
    else
    value_int ="'#{value}'"
  end
  key = key_value_pair.keys.first
  
    sql = <<-SQL
    SELECT * FROM #{self.table_name} WHERE #{key} = #{value_int}
    SQL
    DB[:conn].execute(sql)
  end
end