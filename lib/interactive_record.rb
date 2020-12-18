require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def initialize(options = {})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.table_name
    self.to_s.pluralize.downcase
  end

  def self.column_names
    sql = "pragma table_info('#{table_name}')"
    table = DB[:conn].execute(sql)

    column_names = []
    table.each do |row|
      column_names << row["name"]
    end

    column_names.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if do |column_name|
      column_name === "id"
    end.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |column_name|
      values << "'#{send(column_name)}'" unless send(column_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(attributes)
    value = attributes.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"

    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{attributes.keys.first} = #{formatted_value}
    SQL

    DB[:conn].execute(sql)
  end
end
