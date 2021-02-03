require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.column_names
    sql = "PRAGMA table_info(#{table_name});"
    table_info = DB[:conn].execute(sql)

    table_info.map { |column_info| column_info['name'] }.compact
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attributes_hash)
    criteria = attributes_hash.keys.map { |column| "#{column} = ?"  }.join(' AND ')
    sql = "SELECT * FROM #{table_name} WHERE #{criteria}"

    DB[:conn].execute(sql, *attributes_hash.values)
  end

  def initialize(options = {})
    options.each do |key, value|
      send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  # def values_for_insert
  #   col_names_for_insert.map do |col|
  #     col_value = send(col)
  #   end
  # end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  # saves the student to the db

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def insert
    sql = <<~SQL
          INSERT INTO #{table_name_for_insert}
          (#{col_names_for_insert.join(', ')})
          VALUES (#{value_placeholders})
          SQL

    DB[:conn].execute(sql, values_for_insert)
    id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")
    self.id = id.first['last_insert_rowid()']
  end

  def value_placeholders
    (1..col_names_for_insert.size).map {'?'}.join(',')
  end
end

  