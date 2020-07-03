require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    def self.table_name
        "#{self.to_s.downcase}s"
    end

    def self.column_names
        DB[:conn].results_as_hash = true
        table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
        table_info.map do |column|
            column['name']
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
        self.class.column_names.reject!{|col_name| col_name == "id"}.join(", ")
    end

    "'Sam', '11'"

    def values_for_insert
        self.class.column_names.collect do |col_name|
            "'#{send(col_name)}'" if col_name!="id"
        end.compact.join(", ")
    end

    def save

        DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
            VALUES (#{values_for_insert})")

        @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]

    end

    def self.find_by_name(name)
        sql = <<-SQL 
        SELECT * FROM #{table_name}
        WHERE name = ?
        SQL

        DB[:conn].execute(sql, name)
    end

    def self.find_by(hash)
        sql = <<-SQL
        SELECT * FROM #{table_name}
        WHERE #{hash.keys.first}= ?
        SQL

        DB[:conn].execute(sql, "#{hash.values.first}")

  
    end
end