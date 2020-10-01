require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true
        sql = "PRAGMA table_info('#{table_name}')"
        table_contents = DB[:conn].execute(sql)
        column_names = []
        table_contents.each do | row |
            column_names << row["name"]
        end
        column_names.compact
    end

    def initialize(options = {})
        options.each do | varName, varVal |
            self.send("#{varName}=", varVal)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def values_for_insert
        values = []
        self.class.column_names.each do | selectedCol |
            values << "'#{send(selectedCol)}'" unless send(selectedCol).nil?
        end
        values.join(", ")
    end

    def col_names_for_insert
        self.class.column_names.delete_if{ | col | col == "id"}.join(", ")
    end

    # def save
    #     sql = <<-SQL 
    #         INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    #         VALUES (#{values_for_insert})
    #     SQL
    #     DB[:conn].execute(sql)
    #     binding.pry
    #     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    # end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
      end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)
    end

  #  def self.find_by(inputHash)
   #     keysArray = inputHash.keys
    #    keysString = []
     #   valuesArray = inputHash.values
      #  keysArray.each do | selectedKey |
      #      keysString << selectedKey.to_s
       # end
       # sql = "SELECT * FROM #{self.table_name} WHERE #{keysString[0]} = #{valuesArray[0]}"
       # i = 1
       # while (i < keysString.length)
       #     sql += " AND #{keysString[i]} = #{valuesArray[i]}"
       #     i += 1
       # end
       # binding.pry
       # DB[:conn].execute(sql)
    #end

    def self.find_by(hash)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{hash.keys.join} = '#{hash.values.join}'")
    end

end