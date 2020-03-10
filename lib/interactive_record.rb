require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        sql = "PRAGMA table_info('#{table_name}')"
        table_info = DB[:conn].execute(sql)
        
        table_info.map do |row|
            row["name"]
        end.compact
    end

    def initialize(options={})
        options.each do |property, value|
            self.send("#{property}=", value)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(', ')
    end

    def values_for_insert
        self.class.column_names.map do |col_name|
             "'#{send(col_name)}'" unless send(col_name).nil?
        end.compact.join(", ")
    end

    def save
        DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)
    end
    
    def self.find_by(attribute)
        key = attribute.keys[0].to_s
        value = attribute.values[0]
        
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{key} = ?", value)
    end
  
end