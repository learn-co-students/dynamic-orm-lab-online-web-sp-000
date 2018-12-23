require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"
    column_names = []
    table_info = DB[:conn].execute(sql)
    table_info.each do |column|
      column_names << column['name']
    end
    column_names.compact
  end

  self.column_names.each do |attribute|
    attr_accessor attribute.to_sym
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def initialize(attribute={})
    attribute.each do |attribute, value|
      self.send("#{attribute}=", value)
    end
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

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE name = '#{name}'
    SQL

    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    column = attribute.to_a.flatten[0].to_s
    value = attribute.to_a.flatten[1]

    if value.to_i > 0
       sql = "SELECT * FROM #{self.table_name} WHERE #{column} = #{value};"
     else
       sql = "SELECT * FROM #{self.table_name} WHERE #{column} = '#{value}';"
     end
    DB[:conn].execute(sql)
  end

end
