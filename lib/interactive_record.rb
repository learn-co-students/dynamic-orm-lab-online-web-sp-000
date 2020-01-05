require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def initialize(opt = {})
   opt.each { |key, val| self.send("#{key}=", val) }
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end
  
  def save
    sql = <<-SQL
    INSERT INTO 
    ? (?) VALUES (?)
    SQL
    
    DB[:conn].execute(sql, table_name_for_insert, col_names_for_insert, [values_for_insert])
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  
  
  def values_for_insert
    self.class.column_names.map do |col_name|
      "'#{send(col_name)}'" if !send(col_name).nil?
    end.compact.join(", ")
  end
    
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{table_name}')"
 
    table_info = DB[:conn].execute(sql)
    column_names = []
 
    table_info.each do |column|
      column_names << column["name"]
    end
 
    column_names.compact
  end
  
end