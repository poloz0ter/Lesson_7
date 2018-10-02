require_relative 'station.rb'
require_relative 'route.rb'
require_relative 'train.rb'
require_relative 'wagon.rb'
require_relative 'cargo_train.rb'
require_relative 'passenger_train.rb'
require_relative 'cargo_wagon.rb'
require_relative 'passenger_wagon.rb'

class Interface
  def initialize
    @stations = []
    @trains = []
    @wagons = []
    @routes = []
  end

  def create_station
    begin
      puts "Введите название станции: "
      name = gets.chomp
      station = Station.new(name)
    rescue StandardError => e
      puts e.message
      retry
    end
      @stations << station
      puts "Станция #{station.name} создана!"
  end

  def create_train
    begin
      puts "Введите номер поезда: "
      number = gets.chomp
      puts "Введите тип поезда (пассажирский или грузовой): "
      type = gets.chomp.downcase
        if type == "грузовой"
          train = CargoTrain.new(number)
        elsif type == "пассажирский"
          train = PassengerTrain.new(number)
        else
          raise "Неверный тип поезда!"
        end
    rescue StandardError => e
      puts e.message
      retry
    end
    @trains << train
    puts "Поезд №#{train.number} создан!"
  end

  def create_route
    begin
      @stations.each_with_index { |station, index| puts "#{index + 1}.#{station.name}" }
      puts "Выберите начальную станцию:"
      from = gets.to_i - 1
      puts "Выберите конечную станцию:"
      to = gets.to_i - 1
      raise "Такой станции не существует" if (from+1) > @stations.size || (to+1) > @stations.size
      raise "Некорректный ввод" if from < 0 || to < 0
      route = Route.new(@stations[from], @stations[to])
    rescue RuntimeError => e
      puts e.message
      retry
    end
    @routes << route
    puts "Маршрут #{@stations[from].name} - #{@stations[to].name} построен!"
  end

  def edit_route
    puts "Выберите станцию: "
    @stations.each_with_index { |station, index| puts "#{index + 1}.#{station.name}" }
    @station_choice = gets.to_i - 1
    puts "Выберите маршрут: "
    @routes.each_with_index { |route, index| puts "#{index + 1}.#{route.from.name} - #{route.to.name}" }
    @route_choice = gets.to_i - 1
    raise "Такой станции не существует" if (@station_choice+1) > @stations.size
    raise "Такого маршрута не существует" if (@route_choice+1) > @routes.size
    raise "Некорректный ввод" if @station_choice < 0 || @route_choice < 0
    rescue StandardError => e
      puts e.message
      retry
  end

  def add_station_to_route
    begin
    edit_route
    raise "Станция уже в маршруте!" if @routes[@route_choice].stations.include? @stations[@station_choice]
    rescue StandardError => e
      puts e.message
      retry
    end
    @routes[@route_choice].add_station(@stations[@station_choice])
    puts "Станция #{@stations[@station_choice].name} добавлена в маршрут!"
  end

  def delete_station_from_route
    begin
    edit_route
    raise "Этой станции нет в маршруте!" unless @routes[@route_choice].stations.include? @stations[@station_choice]
    raise "Нельзя удалить первую и последнюю станции" if @stations[@station_choice] == @stations.first || @stations[@station_choice] == @stations.last
    rescue StandardError => e
      puts e.message
      retry
    end
    @routes[@route_choice].delete_station(@stations[@station_choice])
    puts "Станция #{@stations[@station_choice].name} удалена из маршрута!"
  end

  def add_route_to_train
    begin
      @routes.each_with_index { |route, index| puts "#{index + 1}.#{route.from.name} - #{route.to.name}" }
      puts "Выберите маршрут:"
      @route_choice = gets.to_i - 1
      raise "Такого маршрута не существует" if (@route_choice+1) > @routes.size || @route_choice < 0
      @trains.each_with_index { |train, index| puts "#{index + 1}.#{train.number}" }
    rescue StandardError => e
      puts e.message
      retry
    end

    begin
      puts "Выберите поезд:"
      train_choice = gets.to_i - 1
      raise "Такого поезда не существует" if (train_choice+1) > @trains.size || train_choice < 0
      @trains[train_choice].route = @routes[@route_choice]
    rescue StandardError => e
      puts e.message
      retry
    end
    puts "Поезд №#{@trains[train_choice].number} выставлен на маршрут!"
  end

  def edit_wagons
    begin
      puts "1.Добавить вагон 2.Удалить вагон"
      input = gets.to_i
      raise "Некорректный ввод" unless input == 1 || input == 2
    rescue StandardError => e
      puts e.message
      retry
    end
    add_wagon_to_train if input == 1
    delete_wagon_from_train if input == 2
  end

  def add_wagon_to_train
    begin
      puts "Введите тип вагона(пассажирский или грузовой)"
      type = gets.chomp.downcase
        if type == "грузовой"
          wagon = CargoWagon.new
          selected_trains = @trains.select { |train| train.is_a? CargoTrain }
        elsif type == "пассажирский"
          wagon = PassengerWagon.new
          selected_trains = @trains.select { |train| train.is_a? PassengerTrain }
        else
          raise 'Неверный тип'
        end
    rescue StandardError => e
      puts e.message
      retry
    end

    begin
      selected_trains.each_with_index { |train, index| puts "#{index + 1}.#{train.number}" }
      puts "Выберите поезд:"
      input = gets.to_i - 1
      raise "Такого поезда не существует" if (input+1) > selected_trains.size || input < 0
    rescue StandardError => e
      puts e.message
      retry
    end
      selected_trains[input].add_wagon(wagon)
      puts "Вагон прицеплен."
  end

  def delete_wagon_from_train
    begin
      @trains.each_with_index { |train, index| puts "#{index + 1}.#{train.number}" }
      puts "Выберите поезд:"
      input = gets.to_i - 1
      raise "Некорректный ввод" if (input+1) > @trains.size || input < 0
      raise "У поезда нет ни одного вагона" if @trains[input].wagons == 0
    rescue StandardError => e
      puts e.message
      retry
    end
    @trains[input].delete_wagon
    puts "Вагон отцеплен."
  end

  def change_directory
    begin
      @trains.each_with_index { |train, index| puts "#{index + 1}.#{train.number}" }
      puts "Выберите поезд:"
      @our_train_indx = gets.to_i - 1
      raise "Некорректный ввод" if (@our_train_indx+1) > @trains.size || @our_train_indx < 0
    rescue StandardError => e
      puts e.message
      retry
    end

    begin
      puts "Поезд находится на станции #{@trains[@our_train_indx].current_station.name}"
      print "Маршрут поезда: "
      @trains[@our_train_indx].route.stations.each { |st| print " #{st.name}  " }
      puts "\nКуда двигаться? 1.Вперед  2.Назад"
      input = gets.to_i
      raise "Некорректный ввод" unless input == 1 || input == 2
    rescue StandardError => e
      puts e.message
      retry
    end
    train_forward if input == 1
    train_backward if input == 2
    puts "Поезд теперь находится на станции #{@trains[@our_train_indx].current_station.name}"

  end

  def train_forward
    @trains[@our_train_indx].go_forward
  end

  def train_backward
    @trains[@our_train_indx].go_backward
  end

  def show_stations
    @stations.each { |station| puts station.name}
  end

  def show_trains_on_station
    begin
      puts "Выберите станцию: "
      @stations.each_with_index { |station, index| puts "#{index + 1}.#{station.name}" }
      input = gets.to_i - 1
      raise "Такой станции не существует" if (input+1) > @stations.size || input < 0
    rescue StandardError => e
      puts e.message
      retry
    end
    @stations[input].trains.each { |train| puts "#{train.number}" }
  end

  def run
    loop do
      puts
      puts "Что вы хотите сделать?
      1.Создать станцию                 2.Создать поезд
      3.Создать маршрута                4.Добавить станцию в маршрут
      5.Удалить станцию из маршрута     6.Назначить маршрут поезду
      7.Добавить/отцепить вагон         8.Переместиться вперед или назад
      9.Показать список станций         10.Показать список поездов на станции
      0.Выход"
      print "Ввод: "
      choice = gets.to_i

      case choice
      when 1
        then create_station
      when 2
        then create_train
      when 3
        then create_route
      when 4
        then add_station_to_route
      when 5
        then delete_station_from_route
      when 6
        then add_route_to_train
      when 7
        then edit_wagons
      when 8
        then change_directory
      when 9
        then show_stations
      when 10
        then show_trains_on_station
      when 0
        then exit
      else
        puts "Некорректный ввод."
      end
    end
  end
end

Interface.new.run