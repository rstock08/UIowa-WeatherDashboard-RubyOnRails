

# Step to visit the weather tab
Given /^I am on the search weather tab$/ do
  visit weather_path
end

When /^I search for weather in the city "(.*?)"$/ do |city|
  visit weather_path
  fill_in 'searched_city_city_name', :with => city
  click_button 'Search'
end

When /^I click on the button labled "(.*?)"$/ do |linktext|
  #click_button "#{linktext}"
  click_on "#{linktext}"
  
  # Old version before updated UI (buttons instead of hyperlinks)
  #formatted_text = URI.encode(linktext)
  #visit("/weather/ChIJQT-zBHaRyFYR42iEp1q6fSU/#{formatted_text}")
end

Then /^I should see a button labled "([^\"]*)"$/ do |text|
  expect(page).to have_button(text)
end

Then /^I should see weather information$/ do
  # Need to add more here
  # check for tables and generic table content? not sure what to do.
  expect(page).to have_content('Current Weather for')
  expect(page).to have_content('Daily Forecast')
  expect(page).to have_content('Tri-hourly Forecast For Today')
end
 


