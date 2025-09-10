module GeolocationHelper
  # Helper methods for geolocation functionality
  def format_location_name(location)
    parts = []
    parts << location[:city] if location[:city].present?
    parts << location[:state] if location[:state].present?
    parts << location[:country] if location[:country].present?

    if parts.any?
      parts.join(", ")
    else
      location[:name]
    end
  end

  def format_coordinates(latitude, longitude)
    "#{latitude.to_f.round(6)}, #{longitude.to_f.round(6)}"
  end
end
