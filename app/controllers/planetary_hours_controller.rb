class PlanetaryHoursController < ApplicationController
  def index
    # Default to current location or a default location
    @latitude = params[:latitude]&.to_f || 40.7128  # New York default
    @longitude = params[:longitude]&.to_f || -74.0060
    @date = params[:date]&.to_date || Date.current

    if @latitude && @longitude
      @planetary_hours = calculate_planetary_hours
    end
  end

  def calculate
    @latitude = params[:latitude]&.to_f
    @longitude = params[:longitude]&.to_f
    @date = params[:date]&.to_date || Date.current

    if @latitude && @longitude
      @planetary_hours = calculate_planetary_hours
    else
      @error = "Please provide valid latitude and longitude"
    end

    respond_to do |format|
      format.html
      format.json { render json: @planetary_hours }
    end
  end

  def search_locations
    query = params[:q]
    if query.present?
      begin
        results = Geocoder.search(query, limit: 10)
        locations = results.map do |result|
          {
            name: result.display_name,
            latitude: result.latitude,
            longitude: result.longitude,
            country: result.country,
            state: result.state,
            city: result.city
          }
        end
        render json: locations
      rescue => e
        Rails.logger.error "Geocoding error: #{e.message}"
        render json: []
      end
    else
      render json: []
    end
  end

  private

  def calculate_planetary_hours
    calculator = PlanetaryHoursCalculator.new(
      latitude: @latitude,
      longitude: @longitude,
      date: @date
    )
    calculator.calculate
  end
end
