require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def initialize(options={})
    options.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def table_name_for_insert
    self.class.table_name
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info(#{table_name})"
    db_columns = DB[:conn].execute(sql)

    columns = []
    db_columns.each do |col|
      columns << col["name"]
    end
    columns
  end

  def col_names_for_insert
    col_names = []
    self.class.column_names.each do |col|
      col_names << col unless col == 'id'
    end
    col_names.join(', ')
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |attribute|
      values << "'#{self.send(attribute)}'" unless self.send(attribute) == nil
    end
    values.join(', ')
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
        VALUES (#{values_for_insert})
      SQL

      DB[:conn].execute(sql)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert};")[0][0]
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(attr)
    attr.each do |key, value|
      sql = <<-SQL
        SELECT *
        FROM #{table_name}
        WHERE #{key.to_s} = ?;
      SQL

      return DB[:conn].execute(sql, value.to_s)
    end
  end
end
