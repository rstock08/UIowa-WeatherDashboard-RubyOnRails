# Test GooglePlaces model
require 'spec_helper'

# GooglePlaces class RSpec tests
describe GooglePlaces do
    
    # Initialize GooglePlaces object
    GooglePlacesTest = GooglePlaces
    
    # Test to see if valid input returns correct information (Happy path).
    it "Find location with valid input" do
        GooglePlacesTest.get_places("Iowa City") == ([{:name=>"Iowa City, IA, United States", :id=>"ChIJF4ggasFB5IcRsIIFh2cYcW0"}, 
        {:name=>"Iowa City, CA, United States", :id=>"ChIJ9dtFjUaonIARTaDDfeLsEgE"}, 
        {:name=>"City of Hinton, Iowa, United States", :id=>"ChIJHUjLsJnmjYcR4whHfvm0oGQ"}, 
        {:name=>"May City, Iowa, United States", :id=>"ChIJAV3kRXzrjIcRkth9iv6B9-w"}, 
        {:name=>"Iowa, LA, United States", :id=>"ChIJUdM3weB7O4YRbaRf7f_aRp0"}])
    end
    
    # Test to see if no input returns default (Sad path).
    it "Find location with invalid input" do
        expect{GooglePlacesTest.get_places(nil)}.to raise_error("no implicit conversion of nil into String")
    end
    
    # Test to see if valid input returns correct geographical information (Happy path).
    it "Get correct geographical information given valid input" do
        GooglePlacesTest.get_coordinates("ChIJF4ggasFB5IcRsIIFh2cYcW0") == ({"lat"=>41.6611277, "lng"=>-91.5301683})
    end
end