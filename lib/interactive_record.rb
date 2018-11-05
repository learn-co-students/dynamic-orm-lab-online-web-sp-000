require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    info = DB[:conn].execute("pragma table_info(#{self.table_name})")
    info.map { |col| col['name'] }.compact
  end

  def initialize(hash={})
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.map { |name| "#{name}" }
    .delete_if {|n| n == 'id'}
    .join(", ")
  end

  def values_for_insert
    self.class.column_names
    .select {|n| n != 'id'}
    .map {|col| "'#{self.send(col)}'"}
    .join(', ')
  end

  def save
    sql ="INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.new.table_name_for_insert} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attr)
    sql = "SELECT * FROM #{self.new.table_name_for_insert} WHERE #{attr.keys.first} = '#{attr[attr.keys.first]}'"
    DB[:conn].execute(sql)
  end

end
