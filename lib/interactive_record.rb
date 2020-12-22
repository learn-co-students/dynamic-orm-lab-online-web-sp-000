require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def initialize(object = {})
        object.each do |prop, v|
            self.send("#{prop}=", v)
        end
    end

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true
        sql = "pragma table_info ('#{table_name}')"

        table_info = DB[:conn].execute(sql)
        columns = []
        table_info.each do |row|
            columns << row["name"]
        end
        columns
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if{|name| name == "id"}.join(", ")
    end

    def values_for_insert
        self.class.column_names.map do |name|
            self.send(name) ? "'#{self.send(name)}'": nil
        end.compact.join(", ")
    end

    def save
        sql = <<-SQL
            INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert})
            VALUES (#{self.values_for_insert})
        SQL

        DB[:conn].execute(sql)

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        DB[:conn].results_as_hash = true
        sql = <<-SQL
            SELECT * FROM #{self.table_name}
            WHERE name = ?
        SQL

        DB[:conn].execute(sql, name)
    end

    def self.find_by(option)
        col_name = nil
        value = nil
        option.each do |k, v|
            col_name = k.to_s
            value = v
        end
        sql = <<-SQL
            SELECT * FROM #{self.table_name}
            WHERE #{col_name} = ?
        SQL

        DB[:conn].execute(sql, value)
    end
end