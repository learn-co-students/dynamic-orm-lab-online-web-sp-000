require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-sql
      PRAGMA table_info(#{self.table_name})
    sql

    table_information = DB[:conn].execute(sql)
    column_names = []
    table_information.each do |hash_info|
      column_names << hash_info["name"]
    end
    column_names
  end

  # Give the initialize method a default argument
  # of an empty hash
  def initialize(attributes={})
    attributes.each {|key, value| self.send("#{key}=", value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  # Return a string with comma-separated values (and a space)
  def col_names_for_insert
    self.class.column_names.delete_if {|column_name| column_name == "id"}.join(", ")
  end

  # Return a string with comma-separated values (and a space)
  # Iterate through the column names and use metaprogramming to read from the attr_reader methods
  # Exclude cases where the value is nil
  def values_for_insert
    return_values = []
    self.class.column_names.each do |column_name|
      return_values << "'#{self.send(column_name)}'" unless self.send(column_name).nil?
    end
    return_values.join(", ")
  end

  # Abstractly save to a database
  def save
    sql = <<-SQL
    INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert})
    VALUES (#{self.values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = '#{name}'")
  end

  # Find by an abstract value
  def self.find_by(attributes)
    sql = <<-SQL
    SELECT * FROM #{self.table_name} WHERE #{attributes.keys[0].to_s} = '#{attributes.values[0]}'
    SQL
    DB[:conn].execute(sql)
  end

end
