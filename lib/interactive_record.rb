require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    columns = []

    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info(#{self.table_name})"

    DB[:conn].execute(sql).each do |col|
      columns << col["name"]
    end

    columns.compact
  end

  def initialize(options={})
    options.each {|k, v| self.send(("#{k}="), v)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |attribute|
      values << "'#{send(attribute)}'" unless send(attribute).nil?
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
        SELECT * FROM #{table_name}
        WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(kv_pair)
    # binding.pry
    col_name = kv_pair.keys.join()
    value = kv_pair.values.join()

    if value.to_i > 0
      value = value.to_i
    end
# binding.pry
    sql = <<-SQL
        SELECT * FROM #{table_name}
        WHERE #{col_name} = "#{value}"
    SQL

    DB[:conn].execute(sql)
  end
end
