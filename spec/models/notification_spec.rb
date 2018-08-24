require 'spec_helper'

describe Notification do
    it 'should send notifications' do
        User.create(:email => "me@mail.com", :user_id => "me", :session_token => "a", :password_digest =>"aaaaaaaaaaaaa",
        "source_1"=>1)
        user = User.first
        user.notifications.create(:city_ids =>"1,2", :city_names => "1", :time =>Time.now.utc.hour.to_i, :current => 1,
        :daily => 1,:hourly => 1,:source =>CONSENSUS)
        user.notifications.create(:city_ids =>"1", :city_names => "1", :time =>Time.now.utc.hour.to_i, :current => 0,
        :daily => 1,:hourly => 0,:source =>FAVORITE)
        all={"weather"=>[{"current"=>[1],"daily"=>[2],"hourly"=>[3]},{"current"=>[],"daily"=>[],"hourly"=>[]},
            {"current"=>[],"daily"=>[],"hourly"=>[]}],
            "consensus"=>{"current"=>[4],"daily"=>[5],"hourly"=>[6]}}
        weather1=[{"city"=>"1", "current"=>[4],"daily"=>[5],"hourly"=>[6]},{"city"=>"2", "current"=>[4],"daily"=>[5],"hourly"=>[6]}]
        weather2=[{"city"=>"1","daily"=>[2]}]
        expect(GooglePlaces).to receive(:get_city).with("1").and_return("1")
        expect(GooglePlaces).to receive(:get_city).with("2").and_return("2")
        expect(GooglePlaces).to receive(:get_coordinates).with("1").and_return({"lat"=>42,"lng"=>96})
        expect(GooglePlaces).to receive(:get_coordinates).with("2").and_return({"lat"=>42,"lng"=>96})
        expect(WeatherAPI).to receive(:get_all_weather).with({"lat"=>42,"lng"=>96},[0,1,2]).and_return(all)
        expect(WeatherAPI).to receive(:get_all_weather).with({"lat"=>42,"lng"=>96},[0,1,2]).and_return(all)
        empty=double('empty')
        expect(UserMailer).to receive(:notification).with('me@mail.com',weather1).and_return(empty)
        expect(empty).to receive(:deliver)
        expect(GooglePlaces).to receive(:get_city).with("1").and_return("1")
        expect(GooglePlaces).to receive(:get_coordinates).with("1").and_return({"lat"=>42,"lng"=>96})
        expect(WeatherAPI).to receive(:get_all_weather).with({"lat"=>42,"lng"=>96},[0]).and_return(all)
        expect(UserMailer).to receive(:notification).with('me@mail.com',weather2).and_return(empty)
        expect(empty).to receive(:deliver)
        Notification.send_notifications
    end
end