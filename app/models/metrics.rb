class Metrics
    include HTTParty
    @@predictions={}
    
    def self.get_avg_source_ratings
        avgRatings = []
        SOURCENAMES.each do |source|
            ratings=User.pluck(source.downcase).compact
            if ratings.length > 0
                rating=ratings.inject(0.0) { |sum, n| sum + n }/ratings.length
            else
                rating = 0
            end
            avgRatings.append({"name"=>source,"rating"=>rating})
        end
        return avgRatings.sort_by { |k| k["rating"] }.reverse
    end
    
    def self.get_accuracy_metrics
        puts "ACCURACY TRIGGERED" 
        time=(Time.now.utc-86400).to_i.to_s
        cities = Prediction.pluck('city_id').uniq
        if !cities.empty?
            accuracy_metric={}
            accuracy_total=[0,0,0]
            cities.each do |city|
                coordinates=GooglePlaces.get_coordinates(city)
                darksky_past=self.get(DARKSKY_BASE_URI+'/forecast/'+DARKSKY_KEY+'/'+coordinates["lat"].to_s+','+coordinates["lng"].to_s+','+time)
                past={}
                past["high"]=darksky_past["daily"]["data"][0]["temperatureHigh"]
                past["low"]=darksky_past["daily"]["data"][0]["temperatureLow"]
                past["wind"]=darksky_past["daily"]["data"][0]["windSpeed"]
                past["humidity"]=darksky_past["daily"]["data"][0]["humidity"]*100
                past["precipitation"]=darksky_past["daily"]["data"][0]["precipAccumulation"]
                if past["precipitation"]
                    past["precipitation"]=past["precipitation"]*2.54
                else
                    past["precipitation"]=0
                end
                source_count=0
                [0,1,2].each do |source|
                    prediction=Prediction.where("city_id='"+city+"' AND source='"+source.to_s+"'")[0]
                    source_accuracy_total=0
                    source_accuracy_total+=[(prediction["high"]-past["high"]).abs.to_f/MAXDIFFS["temperature"],1].min
                    source_accuracy_total+=[(prediction["low"]-past["low"]).abs.to_f/MAXDIFFS["temperature"],1].min
                    source_accuracy_total+=[(prediction["wind"]-past["wind"]).abs.to_f/MAXDIFFS["wind"],1].min
                    source_accuracy_total+=[(prediction["humidity"]-past["humidity"]).abs.to_f/MAXDIFFS["humidity"],1].min
                    source_accuracy_total+=[(prediction["precipitation"]-past["precipitation"]).abs.to_f/MAXDIFFS["precipitation"],1].min
                    accuracy_total[source_count]+=(1-source_accuracy_total/5)*100
                    source_count+=1
                end
            end
            source_count=0
            [0,1,2].each do |source|
                accuracy_metric[SOURCENAMES[source_count].downcase]=accuracy_total[source_count]/5
                source_count+=1
            end
            AccuracyMetric.create(accuracy_metric)
        end
        Prediction.delete_all
        for i in 0..4
            places=[]
            while places.empty?
                places=GooglePlaces.get_places((65 + rand(26)).chr+(65 + rand(26)).chr)
            end
            city_id=places[rand(places.length-1)][:id]
            coordinates=GooglePlaces.get_coordinates(city_id)
            all=WeatherAPI.get_all_weather(coordinates, [DARKSKY,WEATHERUNDERGROUND,OPENWEATHERMAP],false,true,false)
            source_count=0
            day = all["weather"][0]["daily"].keys[0]
            all["weather"].each do |source|
                prediction={"city_id"=>city_id, "source"=>source_count}
                prediction["high"]=source["daily"][day]["high"].to_f
                prediction["low"]=source["daily"][day]["low"].to_f
                prediction["wind"]=source["daily"][day]["wind"].to_f
                prediction["humidity"]=source["daily"][day]["humidity"].gsub('%','').to_f
                prediction["precipitation"]=source["daily"][day]["precipitation"].to_f
                source_count+=1
                Prediction.create!(prediction)
            end
        end
    end
    
    def self.get_recent_accuracy_metrics
        metric = AccuracyMetric.order("created_at").last
        recentAccuracy=[]
        if metric
            SOURCENAMES.each do |source|
                recentAccuracy.append({"name"=>source,"accuracy"=>metric[source.downcase]})
            end
            return recentAccuracy.sort_by { |k| k["accuracy"] }.reverse 
        else
            return []
        end
    end
    
    def self.get_accuracy_over_time
        metrics=AccuracyMetric.order("created_at")
        if metrics.length > 10
            metrics=metrics[metrics.length-10..metrics.length-1]
        end
        darksky=[]
        weatherunderground=[]
        openweathermap=[]
        count = metrics.length-1
        metrics.each do |metric|
            darksky.append([count,metric["darksky"]])   
            weatherunderground.append([count,metric["weatherunderground"]])  
            openweathermap.append([count,metric["openweathermap"]])
            count-=1
        end
        return [{name: "DarkSky", data: darksky},{name: "WeatherUnderground", data: weatherunderground},{name: "OpenWeatherMap", data: openweathermap}]
    end
end