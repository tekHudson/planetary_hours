 class PlanetaryHoursController < ApplicationController
  def index
    @latitude = params[:latitude]&.to_f
    @longitude = params[:longitude]&.to_f
    @date = params[:date]&.to_date || current_date_in_user_timezone
    @planetary_hours = calculate_planetary_hours
  end

  def calculate
    @latitude = params[:latitude]&.to_f
    @longitude = params[:longitude]&.to_f
    @date = params[:date]&.to_date || current_date_in_user_timezone

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


  private

  def current_date_in_user_timezone
    if user_timezone.present?
      Time.current.in_time_zone(user_timezone).to_date
    else
      Date.current
    end
  end

  def user_timezone
    session[:user_timezone] || params[:timezone]
  end

  def calculate_planetary_hours
    return nil if @latitude.blank? || @longitude.blank? || @date.blank?

    calculator = PlanetaryHoursCalculator.new(
      latitude: @latitude,
      longitude: @longitude,
      date: @date
    )
    calculator.calculate
  end
 end
