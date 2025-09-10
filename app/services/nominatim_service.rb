require "net/http"
require "uri"
require "json"

class NominatimService
  BASE_URL = "https://nominatim.openstreetmap.org/search"
  USER_AGENT = "Planetary Hours Calculator (contact@example.com)"

  class << self
    def search(query, limit: 10)
      return [] if query.blank?

      Rails.logger.info "NominatimService searching for: #{query}"

      begin
        # Add delay to respect rate limits (1 request per second)
        sleep(1.1)

        uri = build_uri(query, limit)
        response = make_request(uri)

        if response.is_a?(Net::HTTPSuccess)
          results = JSON.parse(response.body)
          Rails.logger.info "Nominatim returned #{results.length} results"
          format_results(results)
        else
          Rails.logger.error "Nominatim API error: #{response.code} #{response.message}"
          []
        end
      rescue => e
        Rails.logger.error "Nominatim service error: #{e.message}"
        []
      end
    end

    private

    def build_uri(query, limit)
      params = {
        q: query,
        format: "json",
        limit: limit,
        addressdetails: 1,
        countrycodes: "us", # Focus on US results
        dedupe: 1
      }

      uri = URI(BASE_URL)
      uri.query = URI.encode_www_form(params)
      uri
    end

    def make_request(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10
      http.open_timeout = 10

      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = USER_AGENT
      request["Accept"] = "application/json"

      http.request(request)
    end

    def format_results(results)
      results.map do |result|
        {
          name: result["display_name"],
          latitude: result["lat"].to_f,
          longitude: result["lon"].to_f,
          country: result.dig("address", "country"),
          state: result.dig("address", "state"),
          city: result.dig("address", "city") || result.dig("address", "town") || result.dig("address", "village"),
          postcode: result.dig("address", "postcode"),
          place_id: result["place_id"]
        }
      end
    end
  end
end
