require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def initialize(options={})
     options.each { |property, value| self.send("#{property}=", value)}
 end
 def self.table_name
     self.to_s.downcase.pluralize
 end
 def self.column_names
     DB[:conn].results_as_hash = true
     table_info = DB[:conn].execute("pragma table_info(#{self.table_name})")
     table_info.map {|row| row["name"]}.compact
 end
 def table_name_for_insert
     self.class.table_name
 end
 def col_names_for_insert
     self.class.column_names.reject{|e| e == "id"}.join(", ")
 end
 def values_for_insert
  values = []
    self.class.column_names.each{|col_name| self.send(col_name) != nil ? values << "'#{self.send(col_name)}'": nil}
    values.join(", ")
 end
 def save
     sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
     DB[:conn].execute(sql).compact
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
   end
   def self.find_by_name(name)
     DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?",name )
   end
   def self.find_by(value)
      value.map{|v,k| DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE grade = ? OR name = ? ", k,k )}[0]
   end
end
