require 'date'

class WeatherAPI
    include HTTParty
    
    ICON_BASE_URI = 'https://icons.wxug.com/i/c/a/'
    DARKSKY_ICONS = {"clear-day"=>"clear", "clear-night"=>"clear", "wind"=>"clear", "fog"=>"cloudy",
        "partly-cloudy-day"=>"partlycloudy", "partly-cloudy-night"=>"partlycloudy"}
    OPENWEATHERMAP_ICONS = {"01d"=>"clear", "02d"=>"partlycloudy", "03d"=>"cloudy", "04d"=>"cloudy",
        "09d"=>"rain", "10d"=>"rain", "11d"=>"tstorms", "13d"=> "snow", "50d"=>"fog",
        "01n"=>"clear", "02n"=>"partlycloudy", "03n"=>"cloudy", "04n"=>"cloudy",
        "09n"=>"rain", "10n"=>"rain", "11n"=>"tstorms", "13n"=> "snow", "50n"=>"fog"}
    
    def self.get_all_weather(coordinates, sources, current_only=false, daily_only=false, apply_offset=true)
        weather = []
        sources.each do |source|
           weather.append({}); 
        end
        consensus_finder={"current"=>{"temperature"=>[], "humidity"=>[], "wind"=>[]},
        "daily"=>{},
        "hourly"=>{}}
        days = []
        hours = []
        
        response = self.get(DARKSKY_BASE_URI+'/forecast/'+DARKSKY_KEY+'/'+coordinates["lat"].to_s+','+coordinates["lng"].to_s+"?extend=hourly")
        Time.zone=response["timezone"]
        
        if apply_offset
            day=DateTime.strptime(response["currently"]["time"].to_s,'%s').in_time_zone
            utc_day = day.in_time_zone('GMT')
            current_hour=day.strftime("%k").to_i
            current_utc_hour = utc_day.strftime("%k").to_i
            offset = 3- (current_utc_hour % 3)
            end_offset = (24-current_hour)/3
        else
            day=DateTime.strptime(Time.now.utc.day.to_s,'%s')
            offset=0
            end_offset=0
        end
        for i in 0..6
            hours.append((day+(offset+3*i)*3600).strftime("%l %p"))
            consensus_finder["hourly"][(day+(offset+3*i)*3600).strftime("%l %p")]={"temperature"=>[], "precipitation"=>[], "humidity"=>[], "wind"=>[]}
        end
        day=day.next_day(1)
        for i in 1..4
            days.append(day.strftime("%A"))
            consensus_finder["daily"][day.strftime("%A")]={"high"=>[], "low"=>[], "precipitation"=>[], "humidity"=>[], "wind"=>[]}
            day = day.next_day(1)
        end
        
        if sources.include? DARKSKY
            source = {}
            source["current"]={}
            source["current"]["temperature"]=response["currently"]["temperature"]
            if DARKSKY_ICONS.key? response["currently"]["icon"]
                source["current"]["icon"]=ICON_BASE_URI+DARKSKY_ICONS[response["currently"]["icon"]]+'.gif'
            else
                source["current"]["icon"]=ICON_BASE_URI+response["currently"]["icon"]+'.gif'
            end
            source["current"]["wind"]=response["currently"]["windSpeed"]
            source["current"]["humidity"]=(response["currently"]["humidity"]*100).round.to_s+"%"
            if (!current_only)
                source["daily"]={}
                count = 1
                if !apply_offset
                    count=0
                end
                days.each do |day|
                    source["daily"][day]={}
                    day_data=response["daily"]["data"][count]
                    source["daily"][day]["high"]=day_data["temperatureMax"]
                    source["daily"][day]["low"]=day_data["temperatureMin"]
                    source["daily"][day]["precipitation"]=get_darksky_precipitation_total(response["hourly"]["data"],count*24,24)
                    source["daily"][day]["humidity"]=(day_data["humidity"]*100).round.to_s+"%"
                    source["daily"][day]["wind"]=day_data["windSpeed"]
                    if DARKSKY_ICONS.key? day_data["icon"]
                       source["daily"][day]["icon"]=ICON_BASE_URI+DARKSKY_ICONS[day_data["icon"]]+'.gif'
                    else
                        source["daily"][day]["icon"]=ICON_BASE_URI+day_data["icon"]+'.gif'
                    end
                    count = count+1
                end
                
                source["hourly"]={}
                count=0
                hours.each do |hour|
                    source["hourly"][hour]=get_darksky_hourlyaverages(response["hourly"]["data"],count*3+offset,3)
                    count = count + 1
                end
                update_consensus_finder(source, consensus_finder, days, hours)
            else
                update_consensus_finder_current(source,consensus_finder)
            end
            weather[sources.index(DARKSKY)]=source
        end
        
        if sources.include? WEATHERUNDERGROUND
            source = {}
            if(!daily_only)
                source["current"]={}
                response = self.get(WEATHERUNDERGROUND_BASE_URI+'/api/'+WEATHERUNDERGROUND_KEY+'/conditions/q/'+coordinates["lat"].to_s+','+coordinates["lng"].to_s+'.json')
                source["current"]["temperature"]=response["current_observation"]["temp_f"]
                source["current"]["icon"]=ICON_BASE_URI+response["current_observation"]["icon"]+'.gif'
                source["current"]["wind"]=response["current_observation"]["wind_mph"]
                source["current"]["humidity"]=response["current_observation"]["relative_humidity"].to_s
            end
            
            if(!current_only)
                response = self.get(WEATHERUNDERGROUND_BASE_URI+'/api/'+WEATHERUNDERGROUND_KEY+'/forecast10day/q/'+coordinates["lat"].to_s+','+coordinates["lng"].to_s+'.json')
                source["daily"]={}
                count = 1
                days.each do |day|
                    source["daily"][day]={} 
                    day_data=response["forecast"]["simpleforecast"]["forecastday"][count]
                    source["daily"][day]["high"]=day_data["high"]["fahrenheit"]
                    source["daily"][day]["low"]=day_data["low"]["fahrenheit"]
                    source["daily"][day]["precipitation"]=day_data["qpf_allday"]["in"]
                    source["daily"][day]["humidity"]=day_data["avehumidity"].to_s+"%"
                    source["daily"][day]["wind"]=day_data["avewind"]["mph"]
                    source["daily"][day]["icon"]=ICON_BASE_URI+day_data["icon"]+'.gif'
                    count = count+1
                end
                if(!daily_only)
                    response = self.get(WEATHERUNDERGROUND_BASE_URI+'/api/'+WEATHERUNDERGROUND_KEY+'/hourly/q/'+coordinates["lat"].to_s+','+coordinates["lng"].to_s+'.json')
                    source["hourly"]={}
                    count=0
                    hours.each do |hour|
                        source["hourly"][hour]=get_weatherunderground_hourlyaverages(response["hourly_forecast"],count*3+offset,3)
                        count = count + 1
                    end
                    update_consensus_finder(source, consensus_finder, days, hours)
                end
            else
                if !daily_only
                    update_consensus_finder_current(source,consensus_finder)
                end
            end
            weather[sources.index(WEATHERUNDERGROUND)]=source
        end
        
        if sources.include? OPENWEATHERMAP
            source = {}
            if !daily_only
                source["current"]={}
                response = self.get(OPENWEATHERMAP_BASE_URI+'/data/2.5/weather?lat='+coordinates["lat"].to_s+"&lon="+coordinates["lng"].to_s+'&units=imperial&APPID='+OPENWEATHERMAP_KEY)
                source["current"]["temperature"]=response["main"]["temp"]
                source["current"]["icon"]=ICON_BASE_URI+OPENWEATHERMAP_ICONS[response["weather"][0]["icon"]]+'.gif'
                source["current"]["wind"]=response["wind"]["speed"]
                source["current"]["humidity"]=response["main"]["humidity"].to_s+"%"
            end
            if(!current_only)
                response = self.get(OPENWEATHERMAP_BASE_URI+'/data/2.5/forecast?lat='+coordinates["lat"].to_s+"&lon="+coordinates["lng"].to_s+'&units=imperial&APPID='+OPENWEATHERMAP_KEY)
                source["daily"]={}
                count = 0
                days.each do |day|
                    source["daily"][day]=get_openweathermap_dailyaverages(response["list"],count*8+end_offset) 
                    count = count+1
                end
                if !daily_only
                    source["hourly"]={}
                    count=0
                    hours.each do |hour|
                        hour_data = response["list"][count]
                        source["hourly"][hour]={}
                        source["hourly"][hour]["temperature"]=hour_data["main"]["temp"]
                        source["hourly"][hour]["humidity"]=hour_data["main"]["humidity"].to_s + "%"
                        source["hourly"][hour]["wind"]=hour_data["wind"]["speed"]
                        source["hourly"][hour]["precipitation"]=0.0
                        if hour_data.key? "rain" and hour_data["rain"].key? "3h" and hour_data["rain"]["3h"]
                            source["hourly"][hour]["precipitation"]+=hour_data["rain"]["3h"]*0.0393701
                        end
                        if hour_data.key? "snow" and hour_data["snow"].key? "3h" and hour_data["snow"]["3h"]
                            source["hourly"][hour]["precipitation"]+=hour_data["snow"]["3h"]*0.0393701
                        end
                        source["hourly"][hour]["icon"]=ICON_BASE_URI+OPENWEATHERMAP_ICONS[hour_data["weather"][0]["icon"]]+".gif"
                        count = count + 1
                    end
                    update_consensus_finder(source, consensus_finder, days, hours)
                end
            else
                update_consensus_finder_current(source,consensus_finder)
            end
            weather[sources.index(OPENWEATHERMAP)]=source
        end
        
        all={}
        all["weather"]=weather
        
        consensus={"current"=>{}, "daily"=>{}, "hourly"=>{}}
        consensus["current"]["temperature"]=get_consensus(consensus_finder["current"]["temperature"])
        consensus["current"]["wind"]=get_consensus(consensus_finder["current"]["wind"])
        consensus["current"]["humidity"]=get_consensus(consensus_finder["current"]["humidity"]).to_s+ "%"
        consensus_total=0
        consensus_total+=get_consensus_metric(consensus_finder["current"]["temperature"],consensus["current"]["temperature"],MAXDIFFS["temperature"])
        consensus_total+=get_consensus_metric(consensus_finder["current"]["wind"],consensus["current"]["wind"],MAXDIFFS["wind"])
        consensus_total+=get_consensus_metric(consensus_finder["current"]["humidity"],consensus["current"]["humidity"],MAXDIFFS["humidity"])
        consensus["current"]["consensus"]=((1-consensus_total.to_f/(3*sources.length))*100).round(2)
        
        if(!current_only)
            days.each do |day|
                consensus["daily"][day]={}
                consensus["daily"][day]["high"]=get_consensus(consensus_finder["daily"][day]["high"])
                consensus["daily"][day]["low"]=get_consensus(consensus_finder["daily"][day]["low"])
                consensus["daily"][day]["wind"]=get_consensus(consensus_finder["daily"][day]["wind"])
                consensus["daily"][day]["precipitation"]=get_consensus(consensus_finder["daily"][day]["precipitation"])
                consensus["daily"][day]["humidity"]=get_consensus(consensus_finder["daily"][day]["humidity"]).to_s+"%"
                consensus_total=0
                consensus_total+=get_consensus_metric(consensus_finder["daily"][day]["high"],consensus["daily"][day]["high"],MAXDIFFS["temperature"]) 
                consensus_total+=get_consensus_metric(consensus_finder["daily"][day]["low"],consensus["daily"][day]["low"],MAXDIFFS["temperature"]) 
                consensus_total+=get_consensus_metric(consensus_finder["daily"][day]["wind"],consensus["daily"][day]["wind"],MAXDIFFS["wind"])
                consensus_total+=get_consensus_metric(consensus_finder["daily"][day]["precipitation"],consensus["daily"][day]["precipitation"],MAXDIFFS["precipitation"])
                consensus_total+=get_consensus_metric(consensus_finder["daily"][day]["humidity"],consensus["daily"][day]["humidity"],MAXDIFFS["humidity"])
                consensus["daily"][day]["consensus"]=((1-consensus_total.to_f/(5*sources.length))*100).round(2)
            end
            
            hours.each do |hour|
                consensus["hourly"][hour]={}
                consensus["hourly"][hour]["temperature"]=get_consensus(consensus_finder["hourly"][hour]["temperature"])
                consensus["hourly"][hour]["wind"]=get_consensus(consensus_finder["hourly"][hour]["wind"])
                consensus["hourly"][hour]["precipitation"]=get_consensus(consensus_finder["hourly"][hour]["precipitation"])
                consensus["hourly"][hour]["humidity"]=get_consensus(consensus_finder["hourly"][hour]["humidity"]).to_s+"%"
                consensus_total=0
                consensus_total+=get_consensus_metric(consensus_finder["hourly"][hour]["temperature"],consensus["hourly"][hour]["temperature"],MAXDIFFS["temperature"]) 
                consensus_total+=get_consensus_metric(consensus_finder["hourly"][hour]["wind"],consensus["hourly"][hour]["wind"],MAXDIFFS["wind"])
                consensus_total+=get_consensus_metric(consensus_finder["hourly"][hour]["precipitation"],consensus["hourly"][hour]["precipitation"],MAXDIFFS["precipitation"])
                consensus_total+=get_consensus_metric(consensus_finder["hourly"][hour]["humidity"],consensus["hourly"][hour]["humidity"],MAXDIFFS["humidity"])
                consensus["hourly"][hour]["consensus"]=((1-consensus_total.to_f/(4*sources.length))*100).round(2)
            end
        end
        
        all["consensus"]=consensus
        
        return all
    end
    
    def self.get_darksky_precipitation_total(hourly_data, startIndex, numhours)
        precip_total = 0
        for i in 0..(numhours-1)
            precip_total = precip_total + hourly_data[startIndex+i]["precipIntensity"]
        end
        return precip_total.round(2)
    end
    
    def self.get_darksky_hourlyaverages(hourly_data, startIndex, numhours)
        temp_total = 0
        humidity_total = 0;
        wind_total = 0;
        icons = []
        for i in 0..(numhours-1)
            temp_total+=hourly_data[i+startIndex]["temperature"]
            humidity_total+=hourly_data[i+startIndex]["humidity"]
            wind_total+=hourly_data[i+startIndex]["windSpeed"]
            icons.append(hourly_data[i+startIndex]["icon"])
        end
        freq=icons.inject(Hash.new(0)){ |h,v| h[v] += 1; h }
        icon=icons.max_by { |v| freq[v] }
        if DARKSKY_ICONS.key? icon
            icon=ICON_BASE_URI+DARKSKY_ICONS[icon]+'.gif'
        else
            icon=ICON_BASE_URI+icon+'.gif'
        end
        return {'temperature'=>(temp_total/numhours).round(2), 'precipitation' => get_darksky_precipitation_total(hourly_data,startIndex,numhours).round(2), 
            'humidity' =>((humidity_total/numhours)*100).round.to_s+"%", 'wind'=>(wind_total/numhours).round(2), 'icon'=>icon}
    end
    
    def self.get_weatherunderground_hourlyaverages(hourly_data, startIndex, numhours)
        temp_total = 0
        humidity_total = 0;
        wind_total = 0;
        precip_total = 0;
        icons = []
        for i in 0..(numhours-1)
            temp_total+=hourly_data[i+startIndex]["temp"]["english"].to_f
            humidity_total+=hourly_data[i+startIndex]["humidity"].to_f
            wind_total+=hourly_data[i+startIndex]["wspd"]["english"].to_f
            precip_total+=hourly_data[i+startIndex]["qpf"]["english"].to_f
            icons.append(hourly_data[i+startIndex]["icon"])
        end
        freq=icons.inject(Hash.new(0)){ |h,v| h[v] += 1; h }
        icon=icons.max_by { |v| freq[v] }
        return {'temperature'=>(temp_total/numhours).round(2), 'precipitation' => precip_total.round(2), 
            'humidity' =>((humidity_total/numhours)).round.to_s+"%", 'wind'=>(wind_total/numhours).round(2), 'icon'=>ICON_BASE_URI+icon+'.gif'}
    end
    
    def self.get_openweathermap_dailyaverages(trihourly_data, startIndex)
        precip_total = 0
        humidity_total = 0;
        wind_total = 0;
        icons = []
        temps=[]
        for i in 0..7
            if trihourly_data[i+startIndex]
                if trihourly_data[i+startIndex].key? "rain" and trihourly_data[i+startIndex]["rain"].key? "3h"
                    precip_total+=trihourly_data[i+startIndex]["rain"]["3h"]*0.0393701
                end
                if trihourly_data[i+startIndex].key? "snow" and trihourly_data[i+startIndex]["snow"].key? "3h"
                    precip_total+=trihourly_data[i+startIndex]["snow"]["3h"]*0.0393701
                end
                temps.append(trihourly_data[i+startIndex]["main"]["temp"])
                humidity_total+=trihourly_data[i+startIndex]["main"]["humidity"]
                wind_total+=trihourly_data[i+startIndex]["wind"]["speed"]
                icons.append(trihourly_data[i+startIndex]["weather"][0]["icon"])
            end
        end
        freq=icons.inject(Hash.new(0)){ |h,v| h[v] += 1; h }
        icon=icons.max_by { |v| freq[v] }
        return {'high' => (temps.max).round(2), 'low' => (temps.min).round(2), 'precipitation' => precip_total.round(2), 
            'humidity' =>(Rational(humidity_total,8)).round.to_s+"%", 'wind'=>(wind_total/8).round(2), 'icon'=>ICON_BASE_URI+OPENWEATHERMAP_ICONS[icon]+'.gif'}
    end
    
    def self.update_consensus_finder(source, consensus_finder, days, hours)
        update_consensus_finder_current(source,consensus_finder)
        days.each do |day|
            update_consensus_finder_daily(source,consensus_finder,day)
        end
        hours.each do |hour|
            update_consensus_finder_hourly(source,consensus_finder, hour)
        end
    end
    
    def self.update_consensus_finder_current(source, consensus_finder)
        consensus_finder["current"]["temperature"].append(source["current"]["temperature"])
        consensus_finder["current"]["wind"].append(source["current"]["wind"])
        consensus_finder["current"]["humidity"].append(source["current"]["humidity"])
    end
    
    def self.update_consensus_finder_daily(source, consensus_finder, day)
        consensus_finder["daily"][day]["high"].append(source["daily"][day]["high"])
        consensus_finder["daily"][day]["low"].append(source["daily"][day]["low"])
        consensus_finder["daily"][day]["precipitation"].append(source["daily"][day]["precipitation"])
        consensus_finder["daily"][day]["wind"].append(source["daily"][day]["wind"])
        consensus_finder["daily"][day]["humidity"].append(source["daily"][day]["humidity"])
    end
    
    def self.update_consensus_finder_hourly(source, consensus_finder, hour)
        consensus_finder["hourly"][hour]["temperature"].append(source["hourly"][hour]["temperature"])
        consensus_finder["hourly"][hour]["precipitation"].append(source["hourly"][hour]["precipitation"])
        consensus_finder["hourly"][hour]["wind"].append(source["hourly"][hour]["wind"])
        consensus_finder["hourly"][hour]["humidity"].append(source["hourly"][hour]["humidity"])
    end
    
    def self.get_consensus(samples)
        divider = samples.length == 0 ? 1 : samples.length
        return (samples.inject(0) { |sum, n| sum + n.to_s.gsub('%','').to_f }/divider).round(2)
    end
    
    def self.get_consensus_metric(samples, average, max_diff)
        if average.to_s.gsub('%','').to_f != 0
            return  samples.inject(0){ |con,n| con+[(n.to_s.gsub('%','').to_f-average.to_s.gsub('%','').to_f).abs/(max_diff),1].min}
        else
            return 0
        end
    end
    
end