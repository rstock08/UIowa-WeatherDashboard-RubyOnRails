describe WeatherAPI do
    
    describe 'searching for weather' do
        it 'should retrieve weather data' do
            days=["Thursday","Friday","Saturday","Sunday"]
            hours=[" 6 PM", " 9 PM", "12 AM", " 3 AM", " 6 AM", " 9 AM", "12 PM"]
            darksky_response={"currently"=>{"temperature"=>1,"windSpeed"=>1,"humidity"=>0.01,"icon"=>"rain","time"=>1509549733,"timezone"=>"CST"},"daily"=>{"data"=>[]},"hourly"=>{"data"=>[]}}
            weatherunderground_current_response={"current_observation"=>{"temp_f"=>2,"wind_mph"=>2,"relative_humidity"=>"2%","icon"=>"cloudy"}}
            weatherunderground_daily_response={"forecast"=>{"simpleforecast"=>{"forecastday"=>[]}}}
            weatherunderground_hourly_response={"hourly_forecast"=>[]}
            openweathermap_current_response={"main"=>{"temp"=>4,"humidity"=>4},"weather"=>[{"icon"=>"01d"}],"wind"=>{"speed"=>4}}
            openweathermap_hourly_response={"list"=>[]}
            
            for i in 0..5
                darksky_response["daily"]["data"].append({"temperatureMax"=>1,"temperatureMin"=>1,"humidity"=>0.01,"windSpeed"=>1,"icon"=>"wind"})
                for j in 0..23
                    darksky_response["hourly"]["data"].append({"temperature"=>1,"humidity"=>0.01,"windSpeed"=>1,"icon"=>"partly-cloudy-night","precipIntensity"=>1})
                end
                weatherunderground_daily_response["forecast"]["simpleforecast"]["forecastday"].append({"high"=>{"fahrenheit"=>3},"low"=>{"fahrenheit"=>2},
                    "avehumidity"=>3,"avewind"=>{"mph"=>3},"icon"=>"fog","qpf_allday"=>{"in"=>3}})
            end
            
            for i in 0..2
                openweathermap_hourly_response["list"].append({"main"=>{"temp"=>9,"humidity"=>9},"wind"=>{"speed"=>9},"weather"=>[{"icon"=>"02n"}],"rain"=>{"3h"=>1}})
            end
            
            for i in 0..5
                for j in 0..6
                    openweathermap_hourly_response["list"].append({"main"=>{"temp"=>9,"humidity"=>9},"wind"=>{"speed"=>9},"weather"=>[{"icon"=>"02n"}],"rain"=>{"3h"=>1}})
                end
                openweathermap_hourly_response["list"].append({"main"=>{"temp"=>4,"humidity"=>9},"wind"=>{"speed"=>9},"weather"=>[{"icon"=>"11n"}],"snow"=>{"3h"=>221.6}})
            end
        
            for i in 0..23
                weatherunderground_hourly_response["hourly_forecast"].append({"temp"=>{"english"=>3},"humidity"=>3,"wspd"=>{"english"=>3},"qpf"=>{"english"=>3},"icon"=>"snow"})
            end
            
            expect(WeatherAPI).to receive(:get).with(DARKSKY_BASE_URI+'/forecast/'+DARKSKY_KEY+'/42,96?extend=hourly').and_return darksky_response
            expect(WeatherAPI).to receive(:get).with(WEATHERUNDERGROUND_BASE_URI+'/api/'+WEATHERUNDERGROUND_KEY+'/conditions/q/42,96.json').and_return weatherunderground_current_response
            expect(WeatherAPI).to receive(:get).with(WEATHERUNDERGROUND_BASE_URI+'/api/'+WEATHERUNDERGROUND_KEY+'/forecast10day/q/42,96.json').and_return weatherunderground_daily_response
            expect(WeatherAPI).to receive(:get).with(WEATHERUNDERGROUND_BASE_URI+'/api/'+WEATHERUNDERGROUND_KEY+'/hourly/q/42,96.json').and_return weatherunderground_hourly_response
            expect(WeatherAPI).to receive(:get).with(OPENWEATHERMAP_BASE_URI+'/data/2.5/weather?lat=42&lon=96&units=imperial&APPID='+OPENWEATHERMAP_KEY).and_return openweathermap_current_response
            expect(WeatherAPI).to receive(:get).with(OPENWEATHERMAP_BASE_URI+'/data/2.5/forecast?lat=42&lon=96&units=imperial&APPID='+OPENWEATHERMAP_KEY).and_return openweathermap_hourly_response
            all = WeatherAPI.get_all_weather({"lat"=>42,"lng"=>96},[0,1,2])
            
            
            expect(all["weather"][0]["daily"].keys).to eq days
            expect(all["weather"][0]["hourly"].keys).to eq hours
    
            icons={"current"=>["https://icons.wxug.com/i/c/a/rain.gif","https://icons.wxug.com/i/c/a/cloudy.gif","https://icons.wxug.com/i/c/a/clear.gif"],
                "daily"=>["https://icons.wxug.com/i/c/a/clear.gif","https://icons.wxug.com/i/c/a/fog.gif","https://icons.wxug.com/i/c/a/partlycloudy.gif"],
                    "hourly"=>["https://icons.wxug.com/i/c/a/partlycloudy.gif","https://icons.wxug.com/i/c/a/snow.gif","https://icons.wxug.com/i/c/a/partlycloudy.gif"]}
            daily_precipitation=[24,3,9]
            hourly_precipitation=[3,9,0.0393701]
            source = 0
            all["weather"].each do |source_hash|
                source_val_current = 2**source
                source_val_daily = 3**source
                expect(source_hash["current"]).to eq ({"temperature"=>source_val_current,"wind"=>source_val_current,"humidity"=>source_val_current.to_s+"%","icon"=>icons["current"][source]})
                source_hash["daily"].keys.each do |day|
                   expect(source_hash["daily"][day]).to eq ({"high"=>source_val_daily,"low"=>source_val_current,"humidity"=>source_val_daily.to_s+"%","wind"=>source_val_daily,"precipitation"=>daily_precipitation[source],"icon"=>icons["daily"][source]}) 
                end
                source_hash["hourly"].keys.each do |hour|
                   expect(source_hash["hourly"][hour]).to eq ({"temperature"=>source_val_daily,"humidity"=>source_val_daily.to_s+"%","wind"=>source_val_daily,"precipitation"=>hourly_precipitation[source],"icon"=>icons["hourly"][source]}) 
                end
                source+=1
            end
            
            expect(all["consensus"]["current"]).to eq ({"temperature"=>2.33,"wind"=>2.33,"humidity"=>"2.33%","consensus"=>90.75})
            all["consensus"]["daily"].keys.each do |day|
                expect(all["consensus"]["daily"][day]).to eq ({"high"=>4.33,"low"=>2.33,"humidity"=>"4.33%","wind"=>4.33,"precipitation"=>12,"consensus"=>62.23})
            end
            all["consensus"]["hourly"].keys.each do |hour|
                expect(all["consensus"]["hourly"][hour]).to eq ({"temperature"=>4.33,"humidity"=>"4.33%","wind"=>4.33,"precipitation"=>4.01,"consensus"=>55.56})
            end
        end
    end
end