require "net/http"
require "uri"
require "json"
require "sun"

class PlanetaryHoursCalculator
  PLANETS = %w[Saturn Jupiter Mars Sun Venus Mercury Moon].freeze

  def initialize(latitude:, longitude:, date:)
    @latitude = latitude.to_f
    @longitude = longitude.to_f
    @date = date.to_date
    @timezone = determine_timezone
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
    begin
      # Create a time object for the date in UTC
      date_time = Time.utc(@date.year, @date.month, @date.day, 12, 0, 0)

      # Calculate sunrise using the sun gem
      sunrise = Sun.sunrise(date_time, @latitude, @longitude)

      # Convert to the determined timezone
      if @timezone && @timezone != "UTC"
        sunrise.in_time_zone(@timezone)
      else
        sunrise
      end
    rescue => e
      Rails.logger.error "Sunrise calculation error: #{e.message}"
      # Fallback to basic calculation
      Time.zone.local(@date.year, @date.month, @date.day, 6, 0, 0).in_time_zone(@timezone)
    end
  end

  def calculate_sunset
    begin
      # Create a time object for the date in UTC
      date_time = Time.utc(@date.year, @date.month, @date.day, 12, 0, 0)

      # Calculate sunset using the sun gem
      sunset = Sun.sunset(date_time, @latitude, @longitude)

      # Convert to the determined timezone
      if @timezone && @timezone != "UTC"
        sunset.in_time_zone(@timezone)
      else
        sunset
      end
    rescue => e
      Rails.logger.error "Sunset calculation error: #{e.message}"
      # Fallback to basic calculation
      Time.zone.local(@date.year, @date.month, @date.day, 18, 0, 0).in_time_zone(@timezone)
    end
  end

  def next_sunrise
    calculate_sunrise + 1.day
  end


  def determine_timezone
    # Calculate timezone based on longitude using Ruby's native capabilities
    # Each 15 degrees of longitude represents 1 hour of time difference from UTC
    offset_hours = (@longitude / 15.0).round

    # Convert to timezone string based on longitude
    case offset_hours
    when -5
      "America/New_York"    # Eastern Time
    when -6
      "America/Chicago"     # Central Time
    when -7
      "America/Denver"      # Mountain Time
    when -8
      "America/Los_Angeles" # Pacific Time
    when -9
      "America/Anchorage"   # Alaska Time
    when -10
      "Pacific/Honolulu"    # Hawaii Time
    else
      "UTC"                 # Default to UTC for other regions
    end
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
