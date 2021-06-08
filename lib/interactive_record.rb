require_relative '../config/environment.rb'
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def initialize(options = {})
    options.each { |property, value| self.send("#{property}=", value) }
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each { |column| column_names << column['name'] }

    column_names.compact
  end

  def values_for_insert
    values = []
    self
      .class
      .column_names
      .each do |col_name|
        values << "'#{send(col_name)}'" unless send(col_name).nil?
      end
    values.join(', ')
  end

  def self.save
    DB[:conn].execute(
      "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (?)",
      [values_for_insert][0],
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
