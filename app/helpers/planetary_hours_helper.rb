module PlanetaryHoursHelper
  def planet_color(planet)
    case planet.downcase
    when "sun"
      "warning"
    when "moon"
      "info"
    when "mercury"
      "secondary"
    when "venus"
      "success"
    when "mars"
      "danger"
    when "jupiter"
      "primary"
    when "saturn"
      "dark"
    else
      "light"
    end
  end

  def planet_symbol(planet)
    case planet.downcase
    when "sun"
      "☉"
    when "moon"
      "☽"
    when "mercury"
      "☿"
    when "venus"
      "♀"
    when "mars"
      "♂"
    when "jupiter"
      "♃"
    when "saturn"
      "♄"
    else
      "○"
    end
  end
end
