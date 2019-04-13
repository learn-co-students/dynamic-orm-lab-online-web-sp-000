require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def initialize(attributes = {})
    attributes.each { |name, value| self.send("#{name}=", value) }
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    table_data = DB[:conn].execute("PRAGMA table_info(#{self.table_name})")
    columns = table_data.map { |column| column["name"]}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |column| column == "id" }.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.map do |column|
      values << "'#{send(column)}'" unless send(column).nil?
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
    sql = "SELECT * FROM #{self.table_name} WHERE #{self.table_name}.name = ?"
    # DB[:conn].execute('SELECT * FROM "students" WHERE name = "Jan"')
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.flatten[0].to_s} = ?"
    DB[:conn].execute(sql, attribute.flatten[1].to_s)
  end
end
