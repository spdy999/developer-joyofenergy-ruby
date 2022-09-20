require 'date'
require 'time'

class PricePlanService
  def initialize(price_plans, electricity_reading_service)
    @price_plans = price_plans
    @electricity_reading_service = electricity_reading_service
  end

  def consumption_cost_of_meter_readings_for_each_price_plan(meter_id)
    readings = @electricity_reading_service.getReadings(meter_id)
    puts readings
    if readings.nil?
      return nil
    else
      Hash[@price_plans.collect { |p| 
        [p.plan_name, calculate_cost(readings, p)]
      }]
    end
  end
  def calculate_cost_by_days(readings, price_plan, days)
    to = DateTime.now
    from = to - days
    wanted_readings = readings.select { |rd|
      # time = rd[:time].to_datetime
      # time = rd[:time].to_time
      time = DateTime.parse(rd[:time])
      from <= time && time <= to
    }
    puts wanted_readings
    calculate_cost(wanted_readings, price_plan)
  end

  def calculate_cost(readings, price_plan)
    average = calculate_average_reading(readings)
    time_elapsed = calculate_time_elapsed(readings)

    averaged_cost = average / time_elapsed

    averaged_cost * price_plan.base_cost
  end

  def calculate_average_reading(readings)
    readings.map {|entry| entry['reading']}.inject(:+) / readings.length
  end

  def calculate_time_elapsed(readings)
    time_span = readings.map {|entry| DateTime.iso8601(entry['time']).to_time}.minmax
    (time_span[1] - time_span[0])/3600.0
  end
end
