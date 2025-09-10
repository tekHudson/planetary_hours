class GeolocationController < ApplicationController
  def search_locations
    query = params[:q]
    Rails.logger.info "Searching for location: #{query}"

    if query.present?
      begin
        Rails.logger.info "Searching for: #{query}"
        results = NominatimService.search(query, limit: 10)
        Rails.logger.info "Found #{results.count} results"

        if results.empty?
          Rails.logger.warn "No results found for query: #{query}"
          render json: { error: "No locations found for '#{query}'. Try a different city or ZIP code." }, status: 404
          return
        end

        Rails.logger.info "Returning locations: #{results}"
        render json: results
      rescue => e
        Rails.logger.error "Geocoding error: #{e.message}"
        Rails.logger.error "Error class: #{e.class}"
        Rails.logger.error "Error details: #{e.inspect}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: "Unable to find location. Please try a different search term or enter coordinates manually." }, status: 500
      end
    else
      Rails.logger.info "No query provided"
      render json: []
    end
  end

  def set_timezone
    if params[:timezone].present?
      session[:user_timezone] = params[:timezone]
      render json: { status: "success", timezone: params[:timezone] }
    else
      render json: { status: "error", message: "No timezone provided" }, status: 400
    end
  end

  private

  def user_timezone
    session[:user_timezone] || params[:timezone]
  end
end
