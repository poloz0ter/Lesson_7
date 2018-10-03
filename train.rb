require_relative 'instance_counter.rb'
require_relative 'company.rb'

class Train
  include InstanceCounter
  include Company
  NUMBER = /.{3}\w*.{2}/

  @@trains_with_numbers = {}
  
  def initialize(number)
    @number = number
    validate!
    @speed = 0
    @wagons = []
    @deleted_wagons = []
    @type = :unknown
    @@trains_with_numbers[number] = self
    register_instance
  end

  def self.find(number)
    @@trains_with_numbers[number]
  end

  attr_reader :speed, :number, :type, :wagons, :current_station, :route

  def speed_up
    @speed += 20
  end

  def stop
    @speed = 0
  end

  def wagons
    @wagons.size
  end

  def add_wagon(wagon)
    @wagons << wagon if @speed.zero?
  end

  def delete_wagon
    if speed.zero?
    @deleted_wagons << @wagons.last
    @wagons.pop
    end
  end

  def route=(route)
    @route = route
    @station_index = 0
    current_station.take_train(self)
  end

  def go_forward
    raise "Это последняя станция" if current_station == @route.stations.last
    current_station.send_train(self)
    @station_index += 1
    current_station.take_train(self)
  end

  def go_backward
    raise "Это первая станция" if current_station == @route.stations.first
    current_station.send_train(self)
    @station_index -= 1
    current_station.take_train(self)
  end

  def current_station
    @route.stations[@station_index]
  end

  def valid?
    begin
      validate!
    rescue
     return false
    end
    true
  end

  private

  def next_station
    @route.stations[@station_index + 1]
  end

  def previous_station
    @route.stations[@station_index - 1]
  end

  def validate!
    raise 'Неверный формат номера' if number !~ NUMBER
    raise 'Некорректный номер' if number.nil? || number.empty?
  end
end
