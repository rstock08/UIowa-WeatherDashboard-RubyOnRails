# Test Weather Locations Controller
require 'spec_helper'

# WeatherLocationsController class RSpec tests
RSpec.describe WeatherLocationsController, :type => :controller do
    
    describe 'with a logged in user' do
        fixtures :users
        before(:each) do
            @current_user = users(:user1)
        end
        it 'should show saved locations' do
            city1=double({'city_id'=>'1', 'city_name'=>'city1'})
            city2=double({'city_id'=>'2','city_name'=>'city2'})
            expect(User).to receive(:find_by_session_token).and_return(@current_user)
            expect(@current_user).to receive(:weather_locations).and_return([city1,city2])
            expect(GooglePlaces).to receive(:get_coordinates).with('1').and_return({"lan"=>7,"lng"=>7})
            expect(GooglePlaces).to receive(:get_coordinates).with('2').and_return({"lan"=>8,"lng"=>8})
            expect(WeatherAPI).to receive(:get_all_weather).with({"lan"=>7,"lng"=>7},[0,1,2],true).and_return({"weather"=>{},"consensus"=>{"current"=>{"consensus"=>0}}})
            expect(WeatherAPI).to receive(:get_all_weather).with({"lan"=>8,"lng"=>8},[0,1,2],true).and_return({"weather"=>{},"consensus"=>{"current"=>{"consensus"=>0}}})
            get :index 
        end
    end
end