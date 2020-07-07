require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
def self.table_name
self.to_s.downcase.pluralize
end

def self.column_names
DB[:conn].results_as_hash = true
sql = "PRAGMA table_info ('#{table_name}')"
table_info = DB[:conn].execute(sql)
column_names = []
table_info.each do |column|
column_names << column['name']
end 
column_names.compact
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
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
end

def values_for_insert 
values = []
self.class.column_names.each do |col_name|
    values << "'#{send(col_name)}'" unless send(col_name).nil?
end
values.join(", ")
end

def self.question_marks
    (self.column_names.size - 1).times.collect{"?"}.join(",")
end

def att_values
    self.class.column_names[1..-1].collect{|att_name|
    self.send(att_name)}
end

def save 
#binding.pry
DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{self.class.question_marks})", *self.att_values)
@id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]

end

def self.find_by_name(name)
DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", [name])
end

def self.find_by(hash)
column_to_search = hash.keys[0].to_s
k = hash.keys
v = hash[k[0]]
DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{column_to_search} = ?", v)
end

#end of SUPERCLASS
end