require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
  
    def self.table_name
        self.to_s.downcase.pluralize
        #u can  get class name just by stringing the class. interesting!
    end

    def self.column_names
        DB[:conn].results_as_hash = true
    #db returns arary of hashes becuase we set the method results_as_hash
        sql = "PRAGMA table_info (#{self.table_name})"
        result = DB[:conn].execute(sql)
        #i tried to avoid string interpolation. but it seems the ? didn't work here.

        columns = []
        result.each do | hash |
            columns << hash["name"]
            #not [:name] because the keys returned to us are not symbols.
        end
        #result looks like: ["id", "name", "album"]
        columns.compact
    end

    def initialize(hash={})
        hash.each do | key, value |
            self.send("#{key}=", value)
            #ex: key is name, value is beyonce. u get self.name= 'beyonce'
        end
        #i think initiatlize is special it always return self
    end


    def save #instance method
    #     sql = "INSERT INTO #{table_name_for_insert}  (#{col_names_for_insert}) VALUES (?)"
    # DB[:conn].execute(sql, [values_for_insert])
    sql = <<-SQL
     INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql )
        #i really tried to not string interpolate but it just somehow didn't work
        #even copynig the sample code doesn't work.... not even the table name, whic his the simplest, works
        #like the question mark was working before.... in the other labs.. what happened???
        # i think the reason is these are STRINGS. like "name, album" is a string, not name, album, so u must string interpolate

        
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if{ | col | col == "id"}.join(", ")
    end

    def values_for_insert
        #using send method.
         #first of all we can't directly ask for all attributes 
        #even if we did, that might include stuff not in the column
        #so using send helps our problem
        values = []
        self.class.column_names.each do | name | 
            values << "'#{send(name)}'" unless send(name).nil?
            #this is the getter, not setter
            #SUBTLE: why is send(name) string interperolated inside a '' inside a " "
            #if we just did values << send(name), once we join we get like " sam, 11"
            #what we need is either as ONE STRING "sam", "11" or as ONE STRING 'sam' '11'
            #hence all that trouble we went thru
        end
        values.join(", ")
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", name)
    end

    def self.find_by(hash)
        #it seems u only need to do for the situtation where they're searching by 1 criteria
        
        # #hash with one key-value pair, hash with 2 key-value pairs, etcc...
        # #we need to create our sql string with a loop
        # #and even create what to put in the execution line with a loop
        # questions = []
        # hash.each do | key, value |
        #     questions << "? = ? AND"
        # end
        # #ex: if hash has {name: "hello", album: "lemonade"} it will make ["? = ? AND", "? = ? AND"]
        # #we get rid of the and IN THE LAST ITEM:
        # questions.last.slice!("AND");
        # questions.join(" ")
        sql ="SELECT * FROM #{self.table_name} WHERE #{hash.keys[0].to_s} = '#{hash[hash.keys[0]]}'  "
        
        result = DB[:conn].execute(sql)
        #,hash.keys[0].to_s, hash[hash.keys[0]]
        
        
    end




end #end class