require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{self.table_name}')" 
    
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names[1..-1].join(", ")
  end

  def values_for_insert
    self.class.column_names[1..-1].collect do |col_name|
     "'#{self.send(col_name)}'"
   end.join(', ')   
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].results_as_hash = true

    sql = <<-SQL
      select * from #{self.table_name} 
      where name = ?
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attr)
    DB[:conn].results_as_hash = true

    sql = <<-SQL
      select * from #{self.table_name} 
      where "#{attr.keys[0].to_s}" = ?
    SQL
  
    DB[:conn].execute(sql, attr.values[0].to_s)
  end

end

InteractiveRecord.column_names