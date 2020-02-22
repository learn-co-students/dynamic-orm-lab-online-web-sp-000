require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
  	self.name.downcase!.pluralize
  end

  def self.column_names
  	sql = <<-SQL
  		PRAGMA table_info(#{self.table_name})
  	SQL
  	table_info = DB[:conn].execute(sql)
  	table_info.map{|hash| hash["name"]}
  end

  def initialize(attributes={})
    attributes.each { |property, value|
    	self.class.my_attr_accessor property.to_sym
      self.send("#{property}=", value)
    }
  end

  def self.my_attr_accessor( method_name )
    inst_variable_name = "@#{method_name}".to_sym
    define_method(method_name) { instance_variable_get inst_variable_name }
    define_method("#{method_name}=") { |new_value| instance_variable_set inst_variable_name, new_value }
  end

  def table_name_for_insert
  	self.class.table_name
  end

  def col_names_for_insert
  	self.class.column_names[1..].join(', ')
  end

  def values_for_insert
  	self.class.column_names.map { |attribute|
  		self.send("#{attribute}")
  	}[1..].map{|value| "'#{value}'"}.join(', ')
	end  

	def save
		sql = "INSERT INTO #{self.class.table_name} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
  	table_info = DB[:conn].execute(sql)
  	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
	end

	def self.find_by_name(name)
		sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
  	table_info = DB[:conn].execute(sql, name)
  end

  def self.find_by(hash)
  	sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys.first.to_s} = '#{hash.values.first}'"
  	DB[:conn].execute(sql)
  end
end