require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def initialize(args = {})
    args.each do |property, value|
      send("#{property}=", value)
    end
  end

  def self.table_name
    to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    DB[:conn].execute(sql).collect { |row| row["name"] }.compact
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute_hash)
    value = attribute_hash.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
    DB[:conn].execute(sql)
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |n| n == "id" }.join(", ")
  end

  def values_for_insert
    self.class.column_names.collect do |col_name|
      "'#{send(col_name)}'" unless send(col_name).nil?
    end.compact.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

end
