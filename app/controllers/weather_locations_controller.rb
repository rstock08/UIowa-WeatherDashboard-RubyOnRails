class WeatherLocationsController < ApplicationController
    before_filter :set_current_user
    
    def index
        if @current_user
            @cities = []
            sorted_sources=[]
            sorted_headings=[]
            sorted_sources.append(@current_user.source_1)
            sorted_headings.append(SOURCENAMES[@current_user.source_1])
            sorted_sources.append(@current_user.source_2)
            sorted_headings.append(SOURCENAMES[@current_user.source_2])
            sorted_sources.append(@current_user.source_3)
            sorted_headings.append(SOURCENAMES[@current_user.source_3])
            sources=sorted_sources
            @headings = sorted_headings
            @current_user.weather_locations.each do |city|
                all=WeatherAPI.get_all_weather(GooglePlaces.get_coordinates(city.city_id),sources,true)
                @cities.append({"name"=>city.city_name, "id"=>city.city_id, "weather"=>all["weather"], "consensus"=>all["consensus"]})
            end
        end
    end
    
    def create
        @current_user.weather_locations.create(:city_name => params[:city_name], :city_id=>params[:city_id])
        redirect_to weather_locations_path
    end
    
    def destroy
        @current_user.weather_locations.find_by_city_id(params[:id]).destroy
        redirect_to weather_locations_path
    end
    
end