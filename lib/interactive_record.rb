require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)

    table_info.map do |column|
      column["name"]
    end.compact
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_without_id
    self.class.column_names.delete_if {|col| col == "id"}
  end

  def col_names_for_insert
    col_names_without_id.join(", ")
  end

  def values_for_insert
    col_names_without_id.map do |col_name|
      "'#{send(col_name)}'"
    end.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]

    self
  end

  def self.find_by_name(name)
    find_by(name: name)
  end

  def self.find_by(attribute)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{attribute.keys[0].to_s} = '#{attribute.values[0].to_s}'
    SQL

    DB[:conn].execute(sql)
  end
end