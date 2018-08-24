class GooglePlaces
   include HTTParty
   BASE_URI = 'https://maps.googleapis.com'
   Autocomplete_Path = '/maps/api/place/autocomplete/json?'
   Place_Details_Path = '/maps/api/place/details/json?'
   API_KEY = 'AIzaSyD-naNTB7anRV6mhnq4jmJKFYuV8R24pdI'
   
   def self.get_places(searched_city)
      response = self.get(BASE_URI+Autocomplete_Path+'input='+searched_city+'&language=en&types=(cities)&key='+API_KEY) 
      cities = []
      response["predictions"].each do |place|
        cities.append({:name=>place["description"], :id=>place["place_id"]})  
      end
      return cities
   end
   
   def self.get_coordinates(city_id)
      response = self.get(BASE_URI+Place_Details_Path+'placeid='+city_id+'&language=en&key='+API_KEY)
      return response["result"]["geometry"]["location"]
   end
   
   def self.get_city(city_id)
      response = self.get(BASE_URI+Place_Details_Path+'placeid='+city_id+'&language=en&key='+API_KEY)
      return response["result"]["formatted_address"]
   end
end