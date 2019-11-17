require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name 
    "#{to_s.downcase}s" #self is implicit here because scope of function is already self... 
  end
  
  def self.dbc(*args) #because I hate having to type DB[:conn].execute(whatever shows up here EVERY SINGLE TIME!)
    DB[:conn].execute(*args)
  end
  
  def self.column_names
    sql = "pragma table_info('#{table_name}')"
    table_info = dbc(sql)
    table_info.collect {|item| item["name"]}.compact #.compact removes nil from the return
  end
  
  def initialize(the_attributes={})
    the_attributes.each {|property, value| self.send("#{property}=", value)}
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end
  
  def values_for_insert #remember that collect returns an array
    self.class.column_names.collect do |col_name|
      "'#{send(col_name)}'" unless send(col_name).nil?
    end.compact.join(", ")
  end
  
  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    InteractiveRecord.dbc(sql)
    @id = InteractiveRecord.dbc("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end
  
  def self.find_by(hash)
    sql = "SELECT * FROM #{table_name} WHERE #{hash.keys[0].to_s} = '#{hash.values[0].to_s}'"
    DB[:conn].execute(sql)
  end
  
  
  
end #end of the class