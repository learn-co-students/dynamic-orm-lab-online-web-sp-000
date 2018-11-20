require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-SQL
      SELECT *
      FROM students
    SQL

    DB[:conn].execute(sql)
  end
  
end
