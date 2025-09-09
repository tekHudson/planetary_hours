class PlanetaryHoursCalculator
  PLANETS = %w[Saturn Jupiter Mars Sun Venus Mercury Moon].freeze

  def initialize(latitude:, longitude:, date: Date.current)
    @latitude = latitude.to_f
    @longitude = longitude.to_f
    @date = date
  end

  def calculate
    sunrise_time = calculate_sunrise
    sunset_time = calculate_sunset

    day_hours = calculate_day_hours(sunrise_time, sunset_time)
    night_hours = calculate_night_hours(sunset_time, next_sunrise)

    {
      date: @date,
      location: { latitude: @latitude, longitude: @longitude },
      sunrise: sunrise_time,
      sunset: sunset_time,
      day_hours: day_hours,
      night_hours: night_hours,
      all_hours: day_hours + night_hours
    }
  end

  private

  def calculate_sunrise
    # Simplified sunrise calculation
    # In a real implementation, this would use proper astronomical algorithms
    # For now, using a basic approximation
    time = Time.zone.local(@date.year, @date.month, @date.day, 6, 0, 0)
    time + (@longitude / 15.0).hours
  end

  def calculate_sunset
    # Simplified sunset calculation
    time = Time.zone.local(@date.year, @date.month, @date.day, 18, 0, 0)
    time + (@longitude / 15.0).hours
  end

  def next_sunrise
    calculate_sunrise + 1.day
  end

  def calculate_day_hours(sunrise, sunset)
    day_duration = sunset - sunrise
    hour_duration = day_duration / 12.0

    (0...12).map do |i|
      start_time = sunrise + (i * hour_duration)
      end_time = start_time + hour_duration

      {
        hour: i + 1,
        planet: PLANETS[i % 7],
        start_time: start_time,
        end_time: end_time,
        duration: hour_duration,
        period: "day"
      }
    end
  end

  def calculate_night_hours(sunset, next_sunrise)
    night_duration = next_sunrise - sunset
    hour_duration = night_duration / 12.0

    (0...12).map do |i|
      start_time = sunset + (i * hour_duration)
      end_time = start_time + hour_duration

      {
        hour: i + 1,
        planet: PLANETS[(i + 6) % 7], # Night hours start with the planet after the last day planet
        start_time: start_time,
        end_time: end_time,
        duration: hour_duration,
        period: "night"
      }
    end
  end
end
