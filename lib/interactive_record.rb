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

    # self.column_names.each do |col_name|
    #     attr_accessor col_name.to_sym
    # end

    def initialize(attributes = {})
        attributes.each do |property, value|
          self.send("#{property}=", value)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
        # when we save our Ruby object, we should not include the id column name or insert a value for the id column
        # turn the array of ["name", "album"] into a comma separated list "name, album"
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ")
    end

    def save
        sql = <<-SQL
          INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
          VALUES (#{values_for_insert})
        SQL
        DB[:conn].execute(sql)
        # DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = <<-SQL
          SELECT * from #{table_name}
          WHERE name = ?
        SQL
        DB[:conn].execute(sql, name)
    end

    def self.find_by(attributes={})
        
        value = attributes.values[0]
        formatted_value = value.class == Fixnum ? value : "#{value}"
        sql = <<-SQL
          SELECT * from #{table_name}
          WHERE #{attributes.keys[0]} = ?
        SQL
        DB[:conn].execute(sql, formatted_value)
    end
  
end