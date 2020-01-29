require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name() self.to_s.downcase.pluralize end

  def self.column_names
    col_names = []
    DB[:conn].results_as_hash = true
    DB[:conn].execute("PRAGMA table_info('#{table_name}')").each { |row| col_names << row["name"] }
    col_names.compact
  end

  def initialize(options={}) options.each { |prop, val| self.send("#{prop}=", val) } end

  def save
    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert() self.class.table_name end

  def values_for_insert
    values = []
    self.class.column_names.each { |col_name| values << "'#{send(col_name)}'" unless send(col_name).nil? }
    values.join(", ")
  end

  def col_names_for_insert() self.class.column_names.delete_if { |col| col == "id" }.join(", ") end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)
  end

  def self.find_by(x)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE ? = ? LIMIT 1", x[x.keys[0]], x.values[0])
  end

end
