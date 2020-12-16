require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_ids = []

    table_info.each do |col|
      column_ids << col["name"]
    end
    column_ids
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM #{table_name}
    WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(option = {})
    search_by = column_names.select { |col| col == option.keys.join } #returns ["name"]
    column_to_use = search_by.join #returns "name"
    value_to_use = option[column_to_use.to_sym]

    sql =<<-SQL
    SELECT * FROM #{table_name}
    WHERE #{column_to_use} = ?
    SQL

    DB[:conn].execute(sql, value_to_use)
  end

  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.select { |col| col != "id"}.join(", ")
  end

  def values_for_insert
    self.class.column_names.collect { | col| "'#{send(col)}'" unless send(col).nil? }.compact.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0]["last_insert_rowid()"]
  end



end
