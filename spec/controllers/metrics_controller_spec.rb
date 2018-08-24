# Test Metrics Controller
require 'spec_helper'

# MetricsController class RSpec tests
RSpec.describe MetricsController, :type => :controller do
    
    
    describe 'showing average metrics' do
        it 'should show average ratings' do
            fake_averages = []
            SOURCENAMES.each do |source|
               fake_averages.append({"name"=>source,"rating"=>1}) 
            end
            expect(Metrics).to receive(:get_avg_source_ratings).and_return fake_averages
            get :index 
            expect(assigns(:avgRatings)).to eq fake_averages
        end
    end
    
    describe 'showing user metrics' do
        fixtures :users
        before(:each) do
            @current_user = users(:user1)
        end
        it 'should show user rankings and ratings' do
            fake_average = {"name"=>"","rating"=>1}
            expect(User).to receive(:find_by_session_token).and_return(@current_user)
            get :index
            expect(assigns(:sourceRankings)).to eq([SOURCENAMES[0],SOURCENAMES[1],SOURCENAMES[2]])
            expect(assigns(:currentRatings)).to eq({"DarkSky"=>1, "OpenWeatherMap"=>2, "WeatherUnderground"=>3})
        end
        
        it 'should update user rankings' do
            expect(User).to receive(:find_by_session_token).and_return(@current_user)
            expect(@current_user).to receive(:update_rankings).with([1,2,0]).and_return({})
            post :rank, {:ranking => {:first => "WeatherUnderground", :second => "OpenWeatherMap", :third => "DarkSky"}}
            expect(response).to redirect_to("/metrics") 
        end
        
        it 'should update user ratings' do
            expect(User).to receive(:find_by_session_token).and_return(@current_user)
            expect(@current_user).to receive(:update_ratings).with({"darksky"=>'3',"weatherunderground"=>'2',"openweathermap"=>'1'}).and_return({})
            post :rate, {:rating => {"DarkSky"=> 3, "OpenWeatherMap"=>1, "WeatherUnderground"=>2}}
            expect(response).to redirect_to("/metrics") 
        end
    end
end