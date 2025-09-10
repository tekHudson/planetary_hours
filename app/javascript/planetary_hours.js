// Planetary Hours Calculator JavaScript
let searchTimeout;

function getCurrentLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      document.getElementById('latitude-field').value = position.coords.latitude.toFixed(6);
      document.getElementById('longitude-field').value = position.coords.longitude.toFixed(6);
      document.getElementById('location-search').value = '';
      hideSuggestions();
      
      // Submit the form to calculate planetary hours
      document.querySelector('form').submit();
    });
  } else {
    alert("Geolocation is not supported by this browser.");
  }
}

function geocodeLocation(event) {
  const locationInput = document.getElementById('location-search');
  const query = locationInput.value.trim();
  
  if (query.length < 3) {
    alert("Please enter a city name or ZIP code (at least 3 characters).");
    return;
  }

  // Show loading state
  const button = event.target;
  const originalText = button.innerHTML;
  button.innerHTML = '<i class="bi bi-hourglass-split me-2"></i>Searching...';
  button.disabled = true;

  fetch(`/geolocation/search_locations?q=${encodeURIComponent(query)}`)
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then(response => {
      console.log('Geocoding response:', response);
      
      // Check if response has an error
      if (response.error) {
        alert(`Error: ${response.error}`);
        return;
      }
      
      // Check if response is an array of locations
      if (Array.isArray(response) && response.length > 0) {
        // Use the first result
        const location = response[0];
        document.getElementById('latitude-field').value = location.latitude.toFixed(6);
        document.getElementById('longitude-field').value = location.longitude.toFixed(6);
        locationInput.value = location.name;
        hideSuggestions();
        console.log('Location set:', location.name, location.latitude, location.longitude);
      } else {
        alert("No location found. Please try a different city or ZIP code.");
      }
    })
    .catch(error => {
      console.error('Error geocoding location:', error);
      alert("Error finding location. Please try again. Check console for details.");
    })
    .finally(() => {
      // Reset button state
      button.innerHTML = originalText;
      button.disabled = false;
    });
}

function searchLocations(query) {
  if (query.length < 3) {
    hideSuggestions();
    return;
  }

  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => {
    fetch(`/geolocation/search_locations?q=${encodeURIComponent(query)}`)
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        console.log('Search response:', data);
        
        // Check if response has an error
        if (data.error) {
          console.error('API error:', data.error);
          hideSuggestions();
          return;
        }
        
        // Check if data is an array
        if (Array.isArray(data)) {
          showSuggestions(data);
        } else {
          console.error('Invalid response format:', data);
          hideSuggestions();
        }
      })
      .catch(error => {
        console.error('Error searching locations:', error);
        hideSuggestions();
      });
  }, 300);
}

function showSuggestions(locations) {
  const suggestionsDiv = document.getElementById('location-suggestions');
  suggestionsDiv.innerHTML = '';

  // Safety check: ensure locations is an array
  if (!Array.isArray(locations)) {
    console.error('showSuggestions called with non-array:', locations);
    hideSuggestions();
    return;
  }

  if (locations.length === 0) {
    hideSuggestions();
    return;
  }

  locations.forEach(location => {
    const item = document.createElement('div');
    item.className = 'list-group-item list-group-item-action bg-dark text-light border-secondary';
    item.style.cursor = 'pointer';
    item.innerHTML = `
      <div class="fw-bold">${location.name}</div>
      <small class="text-muted">${location.latitude.toFixed(6)}, ${location.longitude.toFixed(6)}</small>
    `;
    
    item.addEventListener('click', () => {
      selectLocation(location);
    });
    
    suggestionsDiv.appendChild(item);
  });

  suggestionsDiv.style.display = 'block';
}

function hideSuggestions() {
  document.getElementById('location-suggestions').style.display = 'none';
}

function selectLocation(location) {
  document.getElementById('latitude-field').value = location.latitude.toFixed(6);
  document.getElementById('longitude-field').value = location.longitude.toFixed(6);
  document.getElementById('location-search').value = location.name;
  hideSuggestions();
}

// Timezone detection
function detectTimezone() {
  return Intl.DateTimeFormat().resolvedOptions().timeZone;
}

// Send timezone to server when page loads
function sendTimezoneToServer() {
  const timezone = detectTimezone();
  
  // Store timezone in a hidden field or send via fetch
  const timezoneField = document.getElementById('timezone-field');
  if (timezoneField) {
    timezoneField.value = timezone;
  }
  
  // Also send via fetch to store in session
  fetch('/geolocation/set_timezone', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
    },
    body: JSON.stringify({ timezone: timezone })
  }).catch(error => {
  });
}

// Event listeners
document.addEventListener('DOMContentLoaded', function() {
  // Detect and send timezone
  sendTimezoneToServer();
  
  const locationSearch = document.getElementById('location-search');
  
  if (locationSearch) {
    locationSearch.addEventListener('input', function() {
      searchLocations(this.value);
    });
    
    locationSearch.addEventListener('blur', function() {
      // Delay hiding suggestions to allow clicking on them
      setTimeout(hideSuggestions, 200);
    });
    
    locationSearch.addEventListener('focus', function() {
      if (this.value.length >= 3) {
        searchLocations(this.value);
      }
    });
  }
  
  // Hide suggestions when clicking outside
  document.addEventListener('click', function(event) {
    if (!event.target.closest('#location-search') && !event.target.closest('#location-suggestions')) {
      hideSuggestions();
    }
  });
});

// Calculate planetary hours - handles geocoding and form submission
function calculatePlanetaryHours() {
  const locationInput = document.getElementById('location-search');
  const query = locationInput.value.trim();
  
  // If no location entered, just submit the form
  if (query.length < 3) {
    document.querySelector('form').submit();
    return;
  }

  // Show loading state
  const button = event.target;
  const originalText = button.innerHTML;
  button.innerHTML = '<i class="bi bi-hourglass-split me-2"></i>Calculating...';
  button.disabled = true;

  // First geocode the location
  fetch(`/geolocation/search_locations?q=${encodeURIComponent(query)}`)
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then(response => {
      console.log('Geocoding response:', response);
      
      // Check if response has an error
      if (response.error) {
        alert(`Error: ${response.error}`);
        return;
      }
      
      // Check if response is an array of locations
      if (Array.isArray(response) && response.length > 0) {
        // Use the first result
        const location = response[0];
        document.getElementById('latitude-field').value = location.latitude.toFixed(6);
        document.getElementById('longitude-field').value = location.longitude.toFixed(6);
        locationInput.value = location.name;
        hideSuggestions();
        
        // Now submit the form
        document.querySelector('form').submit();
      } else {
        alert('No locations found. Please try a different search term.');
      }
    })
    .catch(error => {
      console.error('Geocoding error:', error);
      alert('Unable to find location. Please try a different search term or enter coordinates manually.');
    })
    .finally(() => {
      // Restore button state
      button.innerHTML = originalText;
      button.disabled = false;
    });
}

// Make functions globally available for onclick handlers
window.getCurrentLocation = getCurrentLocation;
window.geocodeLocation = geocodeLocation;
window.searchLocations = searchLocations;
window.showSuggestions = showSuggestions;
window.hideSuggestions = hideSuggestions;
window.selectLocation = selectLocation;
window.calculatePlanetaryHours = calculatePlanetaryHours;
