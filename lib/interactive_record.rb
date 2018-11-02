require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].execute("PRAGMA table_info('#{table_name}')").map do |column|
      column["name"]
    end.compact
  end

  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
    self
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    col_names = self.class.column_names
    col_names.delete("id")
    col_names.join(", ")
  end

  def values_for_insert
    col_names = self.class.column_names
    col_names.delete("id")
    col_names.map { |attribute| "'#{self.send(attribute)}'" }.join(", ")
  end

  def save
    save = <<-SQL
      INSERT INTO #{self.class.table_name} (#{col_names_for_insert})
        VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(save)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
  end

  def self.find_by_name(name)
    self.find_by({name: name})
  end

  def self.find_by(option = {})
    property = option.keys.first
    find = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE #{property} = ?
    SQL

    DB[:conn].execute(find, option[property])
  end
end
