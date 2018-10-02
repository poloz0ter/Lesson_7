require_relative 'company.rb'

class Wagon
  include Company
  def initialize(type)
    @type = type
  end

  attr_reader :type
end
