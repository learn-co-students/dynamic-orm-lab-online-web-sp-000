require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
  def self.column_names
    #DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    results = DB[:conn].execute(sql)
    table_columns = []
    results.each {|column|
        table_columns << column["name"]
    }
    table_columns.compact
  end
  def initialize(attributes={})
    attributes.each {|key, value|
        self.send("#{key}=", value)
    }
  end
  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    all_column_names = self.class.column_names
    #binding.pry
    all_column_names.delete("id")
    all_column_names = all_column_names.join(", ")
    all_column_names

  end
  def values_for_insert
    #binding.pry
    processed_columns = self.class.column_names
    processed_columns.delete("id")
    values_insert = ""
    processed_columns.each_with_index {|column, index|
        #binding.pry
        if index == processed_columns.length - 1
            values_insert = values_insert + "'#{send(column)}'"
        else
            values_insert = values_insert + "'#{send(column)}', "
        end

    }
    values_insert
  end
  def save
    
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    #binding.pry
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT * FROM #{self.to_s.downcase.pluralize} WHERE name = ?
    SQL
    #binding.pry
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    #binding.pry
    sql = <<-SQL
    SELECT * FROM #{self.to_s.downcase.pluralize} WHERE #{attribute.keys[0].to_s} = ?
    SQL
    #binding.pry
    DB[:conn].execute(sql, attribute.values[0].to_s)
  end
end