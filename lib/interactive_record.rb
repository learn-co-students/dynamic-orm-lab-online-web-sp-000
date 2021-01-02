require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    DB[:conn].execute("PRAGMA table_info('#{table_name}');").collect {|col_info| col_info["name"]}
  end

  def initialize(options = {})
    options.each {|k,v| self.send("#{k}=",v) unless k == "id"}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|i| i == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |i|
      values << "'#{self.send(i)}'" unless i == "id"
    end
    values.join(", ")
  end
  
  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert});
    SQL

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
      sql = <<-SQL
        SELECT * FROM #{table_name}
        WHERE name = ?;
      SQL

      DB[:conn].execute(sql,name)
  end

  def self.find_by(options)
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{options.keys.first.to_s} = \'#{options.values.first.to_s}\';
    SQL
    
    DB[:conn].execute(sql)
  end
end