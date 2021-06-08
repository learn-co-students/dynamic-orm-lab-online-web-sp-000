require_relative '../config/environment.rb'
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  self.column_names.each { |col_name| attr_accessor col_name.to_sym }

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |col| col == 'id' }.join(', ')
  end

  def save
    DB[:conn].execute(
      "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})",
    )

    @id =
      DB[:conn].execute(
        "SELECT last_insert_rowid() FROM #{table_name_for_insert}",
      )[
        0
      ][
        0
      ]
  end
end
