DARKSKY = 0
WEATHERUNDERGROUND = 1
OPENWEATHERMAP = 2

OPENWEATHERMAP_KEY = '4bb1a233bb3d41614f68caf983941511'
DARKSKY_KEY = '6365713f03b6b9b320b53b810cb939cf'
WEATHERUNDERGROUND_KEY = '6213739a594bcabc'
OPENWEATHERMAP_BASE_URI = 'https://api.openweathermap.org'
DARKSKY_BASE_URI = 'https://api.darksky.net'
WEATHERUNDERGROUND_BASE_URI = 'http://api.wunderground.com'

SOURCENAMES=["DarkSky","WeatherUnderground","OpenWeatherMap"]
MAXDIFFS = {"temperature"=>10, "humidity"=>20, "wind"=>10, "precipitation"=>0.5}
CONSENSUS=0
FAVORITE=1