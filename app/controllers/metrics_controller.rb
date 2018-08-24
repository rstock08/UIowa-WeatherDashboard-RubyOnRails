class MetricsController < ApplicationController
    before_filter :set_current_user
    def index
        @sourceRankings=[]
        puts @current_user
        if @current_user
            @sourceRankings=[SOURCENAMES[@current_user.source_1],SOURCENAMES[@current_user.source_2],SOURCENAMES[@current_user.source_3]]
            if @sourceRankings.index(nil)
                @sourceRankings=["DarkSky","WeatherUnderground","OpenWeatherMap"]
            end
            @currentRatings={}
            SOURCENAMES.each do |source|
                @currentRatings[source]=@current_user.attributes[source.downcase]
            end
        end
        @avgRatings=Metrics.get_avg_source_ratings()
        @recentAccuracy=Metrics.get_recent_accuracy_metrics()
        @accuracyOverTime=Metrics.get_accuracy_over_time()
        
    end
    
    def rank
        if @current_user
            @current_user.update_rankings([SOURCENAMES.index(params[:ranking][:first]),SOURCENAMES.index(params[:ranking][:second]),SOURCENAMES.index(params[:ranking][:third])])
        end
        redirect_to metrics_path
    end
    
    def rate
        if @current_user
            @current_user.update_ratings({"darksky"=>params[:rating]["DarkSky"],"weatherunderground"=>params[:rating]["WeatherUnderground"],"openweathermap"=>params[:rating]["OpenWeatherMap"]})
        end
        redirect_to metrics_path
    end
end