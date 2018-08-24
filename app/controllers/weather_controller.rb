class WeatherController < ApplicationController
    before_filter :set_current_user
    
    def index
        
    end
    
    def search
        @cities = GooglePlaces.get_places(params[:searched_city]['city_name'])
    end
    
    def show

        @owm = params[:source][:openweathermap]
        @ds = params[:source][:darksky]
        @wu = params[:source][:weatherunderground]
        
        sources = []
        @headings = []
        empty = true
        
        if params[:source][:darksky] == '1'
            sources.push( DARKSKY )
            @headings.push( "DarkSky" ) 
            empty = false;
        end
        
        if params[:source][:weatherunderground] == '1'
            sources.push( WEATHERUNDERGROUND )
            @headings.push( "WeatherUnderground" ) 
            empty = false
        end
        
        if params[:source][:openweathermap] == '1'
            sources.push( OPENWEATHERMAP ) 
            @headings.push( "OpenWeatherMap" ) 
            empty = false
        end
        
        
        if empty
            flash[:warning] = "No services selected; please select at least one service before searching."
            redirect_to weather_path
        else
            if @current_user
                sorted_sources=[]
                sorted_headings=[]
                if sources.index(@current_user.source_1)
                    sorted_sources.append(@current_user.source_1)
                    sorted_headings.append(SOURCENAMES[@current_user.source_1])
                end
                if sources.index(@current_user.source_2)
                    sorted_sources.append(@current_user.source_2)
                    sorted_headings.append(SOURCENAMES[@current_user.source_2])
                end
                if sources.index(@current_user.source_3)
                    sorted_sources.append(@current_user.source_3)
                    sorted_headings.append(SOURCENAMES[@current_user.source_3])
                end
                sources=sorted_sources
                @headings = sorted_headings
            end
            all=WeatherAPI.get_all_weather(GooglePlaces.get_coordinates(params[:city].keys[0]),sources)
            @weather= all["weather"]
            @consensus = all["consensus"]
            @city = params[:city][params[:city].keys[0]].keys[0]
            @id = params[:city].keys[0]
            @days=@weather[0]["daily"].keys
            @hours=@weather[0]["hourly"].keys
            @saved_location=false
            if @current_user && @current_user.weather_locations.find_by_city_id(@id)
                @saved_location=true
            end
        end
    end

    
    def self.consensus_class(consensus)
        if (consensus >= 75)
          return "good_consensus"
        else
          return "bad_consensus"
        end
    end
end