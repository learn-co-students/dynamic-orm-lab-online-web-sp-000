require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    #creates a downcased, plural table name based on the Class name
    def self.table_name
        self.to_s.downcase.pluralize
    end

    # Returns an array of SQL column names
    def self.column_names
        DB[:conn].results_as_hash = true
        sql = "pragma table_info('#{table_name}')"

        table_info = DB[:conn].execute(sql)
        column_name = []
        table_info.each {|column| column_name << column["name"]}
        column_name.compact
    end

    #creates an new instance of a student
    #creates a new student with attributes
    def initialize(options={})
        options.each {|key, value| self.send("#{key}=", value)}
    end

    #return the table name when called on an instance of Student
    def table_name_for_insert
        self.class.table_name
    end

    #return the column names when called on an instance of Student
    #does not include an id column
    def col_names_for_insert
        self.class.column_names.delete_if {|column| column == "id"}.join(", ")
    end
  
    #formats the column names to be used in a SQL statement
    def values_for_insert
        values = []
        self.class.column_names.each {|column| values << "'#{send(column)}'" unless send(column).nil?}
        values.join(", ")
    end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
        DB[:conn].execute(sql)
    end

    def self.find_by(attribute_hash)
        value = attribute_hash.values.first
        formatted_value = value.class == Fixnum ? value : "'#{value}'"
        sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
        DB[:conn].execute(sql)
    end

end