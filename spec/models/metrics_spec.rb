require 'spec_helper'

describe Metrics do
    describe 'getting average source ratings' do
        it 'should calculate average ratings' do
            SOURCENAMES.each do |source|
                num = SOURCENAMES.index(source)+1
                expect(User).to receive(:pluck).with(source.downcase).and_return [1,num,num**2] 
            end
            ratings = Metrics.get_avg_source_ratings
            expect(ratings[0]).to eq ({"name"=>SOURCENAMES[2],"rating"=>13.0/3})
            expect(ratings[1]).to eq ({"name"=>SOURCENAMES[1],"rating"=>7.0/3})
            expect(ratings[2]).to eq ({"name"=>SOURCENAMES[0],"rating"=>3.0/3})
        end
    end
    
    describe 'getting source accuracy' do
        it 'should calculate source accuracy metrics' do
            all={"weather" => [{"daily"=>{}},{"daily"=>{}},{"daily"=>{}}]}
            for i in 0..2
                all["weather"][i]["daily"]["day"]={"high"=>i, "low"=>i*2, "wind"=>i*3, "humidity"=>(i*4).to_s, "precipitation"=>i*5}
            end
            for i in 1..5
                expect(GooglePlaces).to receive(:get_places).and_return([{:id => i.to_s}])
                expect(GooglePlaces).to receive(:get_coordinates).with(i.to_s).and_return({"lat"=>42,"lng"=>96})
            end
            expect(WeatherAPI).to receive(:get_all_weather).with({"lat"=>42,"lng"=>96},[0,1,2],false,true,false).exactly(5).times.and_return(all)
            Metrics.get_accuracy_metrics
            past={"daily"=>{"data"=>[{"temperatureHigh"=>1, "temperatureLow"=>2, "windSpeed"=>3, "humidity"=>0.04, "precipAccumulation"=>5}]}}
            for i in 1..5
                expect(GooglePlaces).to receive(:get_coordinates).with(i.to_s).and_return({"lat"=>42,"lng"=>96})
                expect(Metrics).to receive(:get).with(DARKSKY_BASE_URI+'/forecast/'+DARKSKY_KEY+'/42,96,'+(Time.now.utc-86400).to_i.to_s).and_return(past)
            end
            expect(GooglePlaces).to receive(:get_places).at_least(5).times.and_return([{:id => "1"}])
            expect(GooglePlaces).to receive(:get_coordinates).with("1").exactly(5).times.and_return({"lat"=>42,"lng"=>96})
            expect(WeatherAPI).to receive(:get_all_weather).with({"lat"=>42,"lng"=>96},[0,1,2],false,true,false).exactly(5).times.and_return(all)
            expect(AccuracyMetric).to receive(:create).with({"darksky"=>64.0, "weatherunderground"=>80.0, "openweathermap"=>64.0})
            expect(Prediction).to receive(:delete_all)
            Metrics.get_accuracy_metrics
        end
        
        it 'should retrieve recent source accuracy' do
            AccuracyMetric.create({"darksky"=>30, "weatherunderground"=>20, "openweathermap"=>50})
            AccuracyMetric.create({"darksky"=>60, "weatherunderground"=>40, "openweathermap"=>50})
            expect(Metrics.get_recent_accuracy_metrics).to eq([{"name"=>"DarkSky","accuracy"=>60}, {"name"=>"OpenWeatherMap","accuracy"=>50}, {"name"=>"WeatherUnderground","accuracy"=>40}])
            
        end
        
        it 'should retrieve source accuracy over time' do
            for i in 1..5
                AccuracyMetric.create({"darksky"=>30, "weatherunderground"=>20, "openweathermap"=>50})
                AccuracyMetric.create({"darksky"=>60, "weatherunderground"=>40, "openweathermap"=>50})
            end
            AccuracyMetric.create({"darksky"=>70, "weatherunderground"=>40, "openweathermap"=>50})
            darkskydata=[60,30,60,30,60,30,60,30,60,70]
            weatherundergrounddata=[40,20,40,20,40,20,40,20,40,40]
            openweathermapdata=[50,50,50,50,50,50,50,50,50,50]
            for i in 0..9
                darkskydata[i]=[9-i,darkskydata[i]]
                openweathermapdata[i]=[9-i,openweathermapdata[i]]
                weatherundergrounddata[i]=[9-i,weatherundergrounddata[i]]
            end
            expect(Metrics.get_accuracy_over_time).to eq([{:name =>"DarkSky",:data =>darkskydata}, {:name =>"WeatherUnderground",:data =>weatherundergrounddata}, {:name =>"OpenWeatherMap",:data =>openweathermapdata}])    
        end
    end
end