require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    
    table_info = DB[:conn].execute(sql)
    table_info.collect {|table_column| table_column["name"]}.compact
  end
  
  def initialize(attributes = {})
    attributes.each {|key, value| self.send("#{key}=", value)}
  end
  
  def table_name_for_insert 
    self.class.table_name
  end
  
  def col_names_for_insert
    delete_column_name("id").join(", ")
    # Note: For obvious reasons, #delete_column_name is a private method.
  end
  
  def values_for_insert
    values = self.class.column_names.collect do |col_name| 
      "'#{self.send(col_name)}'" unless self.send(col_name).nil?
    end
    
    values.compact.join(", ")
  end
  
  def values_for_insert_v2
    # Due to the difference in how the values are inserted into the database (directly vs. with bound parameters), calling values_for_insert.split(", ") won't work.
    
    # That would cause a Student to have these values: 
    # [{"id"=>1, "name"=>"'Sam'", "grade"=>"'11'", 0=>1, 1=>"'Sam'", 2=>"'11'"}]
    # instead of these values: 
    # [{"id"=>1, "name"=>"Sam", "grade"=>11, 0=>1, 1=>"Sam", 2=>11}]. Tricky bug!!!
    
    self.class.column_names.collect {|col_name| self.send(col_name)}.compact
  end
  
  def save
    # Just to satisfy my need to refactor this thing:
    save_v2
    
    # The following code is probably what they're looking for:
    
    # sql = <<-SQL 
    #   INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    #   VALUES (#{values_for_insert})
    # SQL
    # 
    # DB[:conn].execute(sql)
    # 
    # @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    
    # However, it doesn't sanitize user data. THIS, however, DOES. 
    # Note that since SQLite apparently doesn't have an API for binding a list of items, I have to do this:
    
    # 1. Get a collection of column names and values (best to do that with an array of arrays, instead of a hash in this case).
    # columns_and_values = col_names_for_insert.split(", ").collect do |column| 
    #   [column, self.send(column)]
    # end
    
    # 2. Remove the first column/value array from that collection and store it separately.
    # first_column_and_value = columns_and_values.shift
    # first_column = first_column_and_value[0]
    # first_value = first_column_and_value[1]
    
    # 3. Insert that column/value pair into the table, creating a new row in the process.
    # sql_one = "INSERT INTO #{table_name_for_insert} (#{first_column}) VALUES (?)"
    # DB[:conn].execute(sql_one, first_value)
    
    # 4. Get the newly created id, and store it in @id, which will be used in Step 5.
    # @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    
    # 5. Update the table row (where id = @id) with the remaining column/value pairs.
    # columns_and_values.each do |column_and_value|
    #   column = column_and_value[0]
    #   value = column_and_value[1]
    #   sql_two = "UPDATE #{table_name_for_insert} SET #{column} = ? WHERE id = ?"
    #   
    #   DB[:conn].execute(sql_two, value, self.id)
    # end
    
    # The following code won't work, because it creates TWO rows in the students table, setting grade = nil each time:
    # column_values_hash.each do |key, value|
    #   sql = "INSERT INTO #{table_name_for_insert} (#{key}) VALUES (?)"
    #   DB[:conn].execute(sql, value)
    # end
    
    # This won't work, either (values_for_insert is ONE value being sent to TWO columns):
    # sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (?)"
    # DB[:conn].execute(sql, values_for_insert)
  end
  
  # def column_values_hash
  #  hash = {}
  #  columns = col_names_for_insert.split(", ")
  #  columns.each {|column| hash[column] = self.send(column)}
  #  hash
  # end
  
  def save_v2
    # This is based on the code from the video "Building a Metaprogrammed Abstract ORM"
    
    sql = <<-SQL 
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) 
      VALUES (#{question_marks_for_insert})
    SQL
    
    DB[:conn].execute(sql, *values_for_insert_v2)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def question_marks_for_insert
    self.class.column_names[1..-1].size.times.collect{"?"}.join(", ")
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name)
  end
  
  def self.find_by(attribute_hash)
   
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{attribute_hash.keys[0]} = ?
      LIMIT 1
    SQL
    
    DB[:conn].execute(sql, attribute_hash.values[0])
    
    # This actually WORKS, but it's unnecessary as only ONE attribute is sent to this method (see spec/student_spec.rb):
    # all_attributes = attribute_hash.keys.join(", ")
    # all_values = attribute_hash.values.join(", ")
    # 
    # sql = <<-SQL
    #   SELECT * FROM #{self.table_name}
    #   WHERE #{all_attributes} = ?
    #   LIMIT 1
    # SQL
    # binding.pry
    # DB[:conn].execute(sql, all_values)
    
    # This won't work; without the call to #to_s, it can't prepare a symbol.
    # But WITH the call to #to_s, it returns []. Not sure why...
    # Note: this was another attempt to sanitize my data.
    # sql = "SELECT * FROM #{self.table_name} WHERE ? = ? LIMIT 1"
    # DB[:conn].execute(sql, attribute_hash.keys[0].to_s, attribute_hash.values[0])
  end
  
  private
  
    def delete_column_name(name)
      self.class.column_names.delete_if {|col_name| col_name == name}
    end
    
end
