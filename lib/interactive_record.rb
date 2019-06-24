require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

     DB[:conn].execute(sql)

     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    self.class.column_names.collect do |property, value|
      "'#{self.send(property)}'" unless self.send("#{property}").nil?
    end.compact.join(", ")
  end

  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def self.find_by(attribute={})
    key, value = attribute.first
    sql =<<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{key.to_s} = ?
    SQL
    DB[:conn].execute(sql, value)#, key.to_s, value)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql =<<-SQL
      PRAGMA table_info(#{self.table_name})
    SQL
    DB[:conn].execute(sql).collect{|col| col["name"]}.compact
  end
end
