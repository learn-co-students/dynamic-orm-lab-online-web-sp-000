require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    info = DB[:conn].execute(sql)
    col_names = info.map {|col| col["name"]}
  end

  def initialize(options = {})
    options.each do |key, value|
        self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.reject{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    sql = self.class.column_names.reject{|col| col == "id"}.map {|attr| "'#{send(attr)}'"}.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert}
    (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT * FROM #{table_name}
        WHERE name = ?
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attr_hash)
    binding.pry
    sql = "SELECT * FROM #{table_name} WHERE #{attr_hash.keys[0]} = '#{attr_hash[attr_hash.keys[0]]}'"
    DB[:conn].execute(sql)
  end

end