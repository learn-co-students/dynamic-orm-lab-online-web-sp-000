require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def self.table_name
  #  self.to_s.downcase.pluralize
    "#{self.to_s.downcase}s"
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    column_names = []
    sql = "PRAGMA table_info('#{table_name}')"
    DB[:conn].execute(sql).each do |row|
      column_names << row["name"]
    end
    column_names
  end

  def initialize(hash={})
    hash.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|name| name == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(search_name)
    sql = <<-SQL
        SELECT * FROM #{table_name}
        WHERE name = ?
    SQL
    DB[:conn].execute(sql, search_name)
  end

  def self.find_by(hash)
    key = hash.keys.first.to_s
    value = hash.values.first
    value = "'#{value}'" unless value.class == Fixnum
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE ? = ?
    SQL
    DB[:conn].execute(sql, key, value)
  end

end