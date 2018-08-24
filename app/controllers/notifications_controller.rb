class NotificationsController < ApplicationController
    before_filter :set_current_user
    
    def index
        if @current_user
            notifications = @current_user.notifications
            @notifications=[]
            notifications.each do |notification|
                cities_string=notification["city_names"]
                time = notification[:time]
                if time > 12
                    time = (time-12).to_s+" PM"
                else
                    time = time.to_s + " AM"
                end
                information=""
                if notification[:current]==1
                    information+="Current, "
                end
                if notification[:daily]==1
                    information+="Daily, "
                end
                if notification[:hourly]==1
                    information+="Hourly, "
                end
                sources = ""
                if notification[:source] == CONSENSUS
                    sources="Consensus"
                else
                    sources="Favorite Source"
                end
                @notifications.append({:id => notification[:id], "time"=>time,"cities"=>cities_string, "information"=>information, "sources"=>sources})
            end
            
        end
    end
    
    def new
        @cities = @current_user.weather_locations.flatten
    end
    
    def create
        cities = @current_user.weather_locations.flatten
        cities_string = ""
        city_names=""
        cities.each do |city|
            if params["cities"][city.city_id]=="1"
                cities_string+=city.city_id+","
                city_names+=city.city_name+"<br>"
            end
        end
        puts params
        time = params["time"].to_i
        if params["ampm"]=="PM"
            time+=12
        end
        @current_user.notifications.create(:city_ids =>cities_string, :city_names => city_names, :time =>time, :current =>params["information"]["current"],
        :daily =>params["information"]["daily"],:hourly =>params["information"]["hourly"],:source =>params["type"]["type"])
        redirect_to notifications_path
    end
    
    def destroy
        Notification.delete(params[:id])
        redirect_to notifications_path
    end
    
    def edit
       @cities = @current_user.weather_locations.flatten
       @notification = Notification.find(params[:id])
    end
    
    def update
        cities = @current_user.weather_locations.flatten
        cities_string = ""
        city_names=""
        cities.each do |city|
            if params["cities"][city.city_id]=="1"
                cities_string+=city.city_id+","
                city_names+=city.city_name+"<br>"
            end
        end
        puts params
        time = params["time"].to_i
        if params["ampm"]=="PM"
            time+=12
        end
        Notification.find(params[:id]).update_attributes(city_ids: cities_string, city_names: city_names, time: time, current: params["information"]["current"],
        daily: params["information"]["daily"],hourly: params["information"]["hourly"], source: params["type"]["type"])
        redirect_to notifications_path
         
    end
end