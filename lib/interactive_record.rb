require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
    attr_accessor :id, :name, :grade 

    def self.table_name
        # creates a downcased, plural table name based on the Class name
        self.to_s.downcase.pluralize
    end 

    def self.column_names 
        # returns an array of SQL column names
        sql = "pragma table_info('#{table_name}')"

        table_info = DB[:conn].execute(sql)
        column_names = []
        table_info.each do |row|
            column_names << row["name"]
        end 
        column_names.compact 
    end 

    def initialize(student_attributes={})
        student_attributes.each do |student_property, student_val|
            self.send("#{student_property}=", student_val)
        end 
    end 

    def table_name_for_insert 
        # return the table name when called on an instance of Student
        self.class.table_name
    end 

    def col_names_for_insert 
        # return the column names when called on an instance of Student
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end 

    def values_for_insert 
    end 

    def save 
    end 

    def self.find_by_name(name)
    end 

    def self.find_by(row)
    end 
  
end