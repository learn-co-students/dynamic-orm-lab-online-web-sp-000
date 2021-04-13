require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def initialize(options={})
        options.each do |attribute, value|
            self.send("#{attribute}=", value)            
        end        
    end
    
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true

        sql = "PRAGMA table_info('#{table_name}')"

        table_info = DB[:conn].execute(sql)
        column_names = []

        table_info.each do |column|
            column_names << column["name"]            
        end
        column_names.compact                
    end

    def table_name_for_insert
        self.class.table_name        
    end

    def col_names_for_insert
        self.class.column_names.delete_if  {|col| col == 'id'}.join(", ")      
    end

    def values_for_insert
        values = []
        
        self.class.column_names.each do |col_name|
            values << "'#{self.send(col_name)}'" unless self.send(col_name).nil?            
        end

        values.join(", ")
    end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

        # binding.pry

        # DB[:conn].execute(sql, table_name_for_insert, col_names_for_insert, values_for_insert)
        DB[:conn].execute(sql)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]

    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM #{self.table_name}
            WHERE name = ?
        SQL

        DB[:conn].execute(sql, name)
    end

    

    def self.find_by(attributes)

        # binding.pry
        sql = <<-SQL
            SELECT * FROM #{self.table_name}
            WHERE #{self.attributes_for_find(attributes)}
        SQL

        DB[:conn].execute(sql)
    end

    def self.attributes_for_find(attributes)
        attributes.map do |key, value|
            "#{key.to_sym} = '#{value}'"    
        end.join(" AND ")        
    end

    def scratch
        
        sql = <<-SQL
            SELECT * FROM students
            WHERE 
        SQL
    end

  
end