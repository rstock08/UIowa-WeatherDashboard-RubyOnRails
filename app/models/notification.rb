class Notification < ActiveRecord::Base
    belongs_to :user
    
    def self.send_notifications
        now = Time.now.utc
        notifications = Notification.where("time='"+now.hour.to_s+"'")
        notifications.each do|notification|
            user = User.find(notification.user_id)
            weather=[]
            cities = notification[:city_ids].split(',')
            sources = [user.source_1]
            if notification[:source]==CONSENSUS
                sources=[0,1,2]
            end
            cities.each do |city|
                city_weather={"city"=>GooglePlaces.get_city(city)}
                all=WeatherAPI.get_all_weather(GooglePlaces.get_coordinates(city),sources)
                if notification[:source]==CONSENSUS
                    raw_weather=all["consensus"]
                else
                    raw_weather=all["weather"][0]
                end
                if notification[:current]==1
                    city_weather["current"]=raw_weather["current"]
                end
                if notification[:daily]==1
                    city_weather["daily"]=raw_weather["daily"]
                end
                if notification[:hourly]==1
                    city_weather["hourly"]=raw_weather["hourly"]
                end
                weather.append(city_weather)
            end
            UserMailer.notification(user.email,weather).deliver
            #UserMailer.text_notification(user_cell, weather).deliver
        end
    end
end