require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    name = self.to_s.downcase + "s"
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end


  def initialize(attrs = {})
    attrs.each do |k,v|
      self.send("#{k}=", v)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    values = []
    self.class.column_names.each do |name|
      values << name unless name == "id"
    end
    values.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |name|
      values << "'#{send(name)}'" unless send(name).nil?
    end
    values.join(", ")
  end

  def save
    DB[:conn].execute("INSERT INTO #{self.table_name_for_insert}(#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})")
    @id = DB[:conn].execute("SELECT last_insert_rowid() from #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)

  end

  def self.find_by(attrs)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{attrs.keys.first.to_s} = ?", attrs.values.first)
  end

end
