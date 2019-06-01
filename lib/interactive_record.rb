require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql="PRAGMA table_info ('#{table_name}')"
    column_names=[]
    table_info = DB[:conn].execute(sql)
    table_info.each do |column|
      column_names << column["name"]
    end
    column_names.compact
  end

  def initialize(hash={})
    hash.each do |key,value|
      self.send("#{key}=",value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col|col=="id"}.join(", ")
  end

  def values_for_insert
    #"sam","11"
    #"student.name", "student.grade"
    v=self.class.column_names.delete_if {|col|col=="id"}.collect do |col|

      k=self.send("#{col}").to_s
      "'#{k}'"
    end
    v.join(", ")
  end



  def save
    sql=<<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    self.id=DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].results_as_hash = true
    hash=DB[:conn].execute("SELECT * FROM #{table_name} WHERE name=?",name)[0]
  end

  def self.find_by




end
