require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    
    def initialize(options={})
        options.each do |k,v|
            self.send("#{k}=",v)
        end
    end

    def self.table_name
        self.to_s.downcase.pluralize
    end


    def self.column_names
        DB[:conn].results_as_hash = true
        sql_column_names = "PRAGMA table_info('#{self.table_name}')"
        table_data = DB[:conn].execute(sql_column_names)
        columns = table_data.collect {|col| col['name']}
        columns
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    def values_for_insert
        values = self.class.column_names.collect {|col| "'#{send(col)}'" unless send(col).nil?}.compact
        values.join(", ")
    end

    def save
        sql_save = <<-SQL
        INSERT INTO #{table_name_for_insert}(#{col_names_for_insert}) 
        VALUES (#{values_for_insert})
        SQL
        DB[:conn].execute(sql_save)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
    end

    def self.find_by_name(name)
        sql_find_name = <<-SQL
        SELECT * FROM #{table_name}
        WHERE name = ?
        SQL
        DB[:conn].execute(sql_find_name,name)
    end

    def self.find_by(att)
        # sql_find_by = <<-SQL
        #     SELECT * FROM #{table_name}
        #     WHERE #{att.keys} = #{att.values}
        # SQL
        # DB[:conn].execute(sql_find_by,att)
        value = att.values.first
        formatted_value = value.class == Fixnum ? value : "'#{value}'"
        sql = "SELECT * FROM #{self.table_name} WHERE #{att.keys.first} = #{formatted_value}"
        DB[:conn].execute(sql)
    end


end