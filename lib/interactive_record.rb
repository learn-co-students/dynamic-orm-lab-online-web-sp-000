require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true
        
        sql = "pragma table_info('#{self.table_name}')"

        table_info = DB[:conn].execute(sql)

        table_info.collect {|column|column["name"]}
    end

    def initialize(options = {})
        options.each do |key, value|
            self.send("#{key}=", value)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|column| column == "id"}.join(", ")
    end

    def values_for_insert
        self.class.column_names.collect do |column|
            "'#{self.send(column)}'" unless self.send(column).nil?
        end.compact.join(", ")
    end

    def save
        sql = <<-SQL
            INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert})
            VALUES (#{self.values_for_insert})
        SQL

        DB[:conn].execute(sql)

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM #{self.table_name}
        WHERE name = ?
        SQL

        DB[:conn].execute(sql, name)
    end

    def self.find_by(attribute = nil)
        value = attribute.values[0].is_a?(String) ? "'#{attribute.values[0]}'" : attribute.values[0]

        sql = <<-SQL
        SELECT *
        FROM #{self.table_name}
        WHERE #{attribute.keys[0].to_s} = #{value}
        SQL

        DB[:conn].execute(sql)
    end
end