# Test Weather Controller
require 'spec_helper'

# WeatherController class RSpec tests
RSpec.describe WeatherController, :type => :controller do
    describe 'determining consensus class' do
        it 'should return class based on consensus' do
            expect(WeatherController.consensus_class(75)).to eq("good_consensus")
            expect(WeatherController.consensus_class(74)).to eq("bad_consensus")
        end
    end
    
    describe 'displaying weather' do
        fixtures :users
        before(:each) do
            @current_user = users(:user1)
        end
        it 'should search for cities' do
            cities = [{:name =>"",:id => ""}]
            expect(GooglePlaces).to receive(:get_places).with('city').and_return(cities)
            get :search, {:searched_city=>{'city_name'=>'city'}}
            expect(assigns(:cities)).to eq(cities)
        end
        
        it 'should display weather data' do
            expect(User).to receive(:find_by_session_token).and_return(@current_user)
            all={"weather"=>[{"hourly"=>{},"daily"=>{},"current"=>{}}],"consensus"=>{"current"=>{"consensus"=>0}}}
            expect(GooglePlaces).to receive(:get_coordinates).with('id').and_return ({"lat" => 7,"lng" => 7})
            expect(WeatherAPI).to receive(:get_all_weather).with({"lat" => 7,"lng" => 7},[0,1,2]).and_return(all)
            get :show, {:source =>{:openweathermap => 1, :darksky => 1, :weatherunderground => 1}, :city => {'id'=>{'city'=>'city'}} }
            expect(assigns(:weather)).to eq(all["weather"])
            expect(assigns(:consensus)).to eq(all["consensus"])
            expect(assigns(:city)).to eq('city')
            expect(assigns(:id)).to eq('id')
            expect(assigns(:headings)).to eq(["DarkSky","WeatherUnderground","OpenWeatherMap"])
        end
    end
end