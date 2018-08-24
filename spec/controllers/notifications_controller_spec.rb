# Test Notifications Controller
require 'spec_helper'

# NotificationsController class RSpec tests
RSpec.describe NotificationsController, :type => :controller do
    fixtures :users
    before(:each) do
        @current_user = users(:user1)
    end
    
    it 'should show user notifications' do
        expect(User).to receive(:find_by_session_token).and_return(@current_user)
        expect(@current_user).to receive(:notifications).and_return([{:id => 1,:city_ids =>"1,2", "city_names" => "1", :time =>8, :current => 1,
        :daily => 1,:hourly => 1,:source =>CONSENSUS},{:id => 2, :city_ids =>"1", "city_names" => "1", :time =>14, :current => 0,
        :daily => 1,:hourly => 0,:source =>FAVORITE}])
        get :index
        expect(controller.instance_variable_get('@notifications')).to eq([{:id=>1, "time"=>"8 AM", "cities"=>"1", "information"=>"Current, Daily, Hourly, ", "sources"=>"Consensus"},
        {:id=>2, "time"=>"2 PM", "cities"=>"1", "information"=>"Daily, ", "sources"=>"Favorite Source"}])
    end
    
    it 'should create new notifications' do
        city1=double({:city_id => "1", :city_name => "1", :[] => "1"})
    city2=double({:city_id => "2", :city_name => "2", :[] => "2"})
        expect(User).to receive(:find_by_session_token).and_return(@current_user)
        expect(@current_user).to receive(:weather_locations).and_return([city1,city2])
        get :new
        expect(assigns(:cities)).to eq([city1,city2])
        expect(@current_user).to receive(:weather_locations).and_return([city1,city2])
        notifications=double({:create => {}})
        expect(@current_user).to receive(:notifications).and_return(notifications)
        expect(notifications).to receive(:create).with({:city_ids=>"1,", :city_names=>"1<br>", :time=>0, :current=>"0", :daily=>"1", :hourly=>"0", :source=>"1"})
        post :create, {"cities"=>{"1"=>"1","2"=>"0"},"information"=>{"current"=>"0","daily"=>"1","hourly"=>"0"},"type"=>{"type"=>"1"}}
        expect(response).to redirect_to("/notifications") 
    end
    
    it 'should edit notifications' do
        city1=double({:city_id => "1", :city_name => "1", :[] => "1"})
        city2=double({:city_id => "2", :city_name => "2", :[] => "2"})
        expect(User).to receive(:find_by_session_token).and_return(@current_user)
        expect(@current_user).to receive(:weather_locations).and_return([city1,city2])
        notification=double({:[] => ""})
        allow(notification).to receive(:[]).with("time").and_return(4)
        expect(Notification).to receive(:find).with("1").and_return(notification)
        get :edit, {:id => "1"}
        expect(assigns(:cities)).to eq([city1,city2])
        expect(assigns(:notification)).to eq(notification)
        expect(@current_user).to receive(:weather_locations).and_return([city1,city2])
        expect(Notification).to receive(:find).with("1").and_return(notification)
        expect(notification).to receive(:update_attributes).with({:city_ids=>"1,", :city_names=>"1<br>", :time=>0, :current=>"0", :daily=>"1", :hourly=>"0", :source=>"1"})
        patch :update, {:id => "1","cities"=>{"1"=>"1","2"=>"0"},"information"=>{"current"=>"0","daily"=>"1","hourly"=>"0"},"type"=>{"type"=>"1"}}
        expect(response).to redirect_to("/notifications")
    end
    
    it 'should delete notifications' do
        expect(Notification).to receive(:delete).with("1")
        delete :destroy, {:id => "1"}
        expect(response).to redirect_to("/notifications")     
    end
end