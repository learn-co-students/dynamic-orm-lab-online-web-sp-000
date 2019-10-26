require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  attr_accessor :id, :name, :grade
  def initialize(args = nil)
    if (args != nil)
      args.each {|key, value| self.send("#{key}=", value)}
    end
  end
  def table_name_for_insert
      return self.class.table_name
  end
  def col_names_for_insert
    columns = self.class.column_names
    columns.delete_at(0)
    return columns.join(", ")
  end
  def values_for_insert
    values = [@name, @grade]
    formatted = values.map{ |value| "'" + value.to_s + "'" }
    return formatted.join(", ")
  end
  def save
    sql = <<-SQL
            INSERT INTO students (#{col_names_for_insert}) VALUES (#{values_for_insert})
              SQL
              DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  def self.find_by_name(name)
    sql = <<-SQL
            SELECT * FROM #{self.table_name} WHERE name=?
            SQL
            return DB[:conn].execute(sql, name)
  end
  def self.find_by(args)
    if (args.include?(:name))
      sql = <<-SQL
              SELECT * FROM #{self.table_name} WHERE name=?
              SQL
      return DB[:conn].execute(sql, args[:name])
    else
      sql = <<-SQL
              SELECT * FROM #{self.table_name} WHERE grade=?
              SQL
      return DB[:conn].execute(sql, args[:grade])
    end
  end
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-SQL
            PRAGMA table_info(students)
            SQL
    details = DB[:conn].execute(sql)
    names = []
    details.each do |column|
      names << column["name"]
    end
    return names
  end

end
