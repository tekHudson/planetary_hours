// Planetary Hours Calculator JavaScript
let searchTimeout;

function getCurrentLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      document.getElementById('latitude-field').value = position.coords.latitude.toFixed(6);
      document.getElementById('longitude-field').value = position.coords.longitude.toFixed(6);
      document.getElementById('location-search').value = '';
      hideSuggestions();
    });
  } else {
    alert("Geolocation is not supported by this browser.");
  }
}

function geocodeLocation() {
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

  fetch(`/planetary_hours/search_locations?q=${encodeURIComponent(query)}`)
    .then(response => response.json())
    .then(locations => {
      if (locations.length > 0) {
        // Use the first result
        const location = locations[0];
        document.getElementById('latitude-field').value = location.latitude.toFixed(6);
        document.getElementById('longitude-field').value = location.longitude.toFixed(6);
        locationInput.value = location.name;
        hideSuggestions();
      } else {
        alert("No location found. Please try a different city or ZIP code.");
      }
    })
    .catch(error => {
      console.error('Error geocoding location:', error);
      alert("Error finding location. Please try again.");
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
    fetch(`/planetary_hours/search_locations?q=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(locations => {
        showSuggestions(locations);
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

// Event listeners
document.addEventListener('DOMContentLoaded', function() {
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
