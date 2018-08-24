Feature: Allow a user to find their city when searching for weather
  
Scenario: Searching for a city
  When I search for weather in the city "Anchorage"
  Then I should see a button labled "Anchorage, AK, United States"