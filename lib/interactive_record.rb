require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    column_data = []

    sql = "PRAGMA table_info('#{table_name}')"
    DB[:conn].execute(sql).each {|o| column_data << o["name"]}

    column_data.compact
  end

  def initialize(options = {})
    options.each {|key, value| self.send("#{key}=", value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []

    self.class.column_names.each {|col_name| values << "'#{send(col_name)}'" unless send(col_name).nil?}

    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    key = attribute.collect {|k, v| k.to_s}.join("")
    value = attribute.collect {|k, v| v}.join("")

    sql = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE #{key} = ?
    SQL

    DB[:conn].execute(sql, value)
  end

end
