require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  attr_accessor :id, :name, :grade

  def initialize(hash={})

    @id = hash[:id]
    @name = hash[:name]
    @grade = hash[:grade]

  end

end
