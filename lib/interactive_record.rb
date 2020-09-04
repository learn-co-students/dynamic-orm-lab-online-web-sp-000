require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        sql = "PRAGMA table_info(`#{table_name}`)"
        table_info = DB[:conn].execute(sql)
        column_names = []

        table_info.each do |hash|
            column_names << hash["name"]
        end

        column_names.compact
    end

    # sql = <<-SQL
        
    # SQL
  
end