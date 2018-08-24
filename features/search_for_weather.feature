Feature: Allow the user to see the weather in a given city
  
Scenario: Looking at the weather in a given city
  When I search for weather in the city "Anchorage"
  When I click on the button labled "Anchorage, AK, United States"
  Then I should see weather information