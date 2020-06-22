require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true

        sql ="pragma table_info('#{table_name}')"

        columns = Array.new

        DB[:conn].execute(sql).each do |col|
            columns << col["name"]
        end

        columns.compact
    end

    def initialize(options={})
        options.each do |prop, val|
            self.send("#{prop}=", val)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|x| x == 'id'}.join(', ')
    end

    def values_for_insert
        values = Array.new
        self.class.column_names.each do |attr|
            values << "'#{self.send(attr)}'" unless send(attr).nil?
        end
        values.join(", ")
    end

    def save
        sql = <<-SQL
            INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
            VALUES (#{values_for_insert});
        SQL

        DB[:conn].execute(sql)

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM #{table_name}
        WHERE name = '#{name}'
        SQL
        DB[:conn].execute(sql)
    end

    def self.find_by(attrib)
        sql = <<-SQL
        SELECT * FROM #{table_name} WHERE #{attrib.keys[0]} = '#{attrib.values[0]}'
        SQL
        DB[:conn].execute(sql)
    end

end