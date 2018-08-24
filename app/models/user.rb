class User < ActiveRecord::Base
    has_many :weather_locations
    has_many :notifications
    has_secure_password
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    def User::create_user!(user_params)
        before_save { |user| user.email = user.email.downcase }
        validates :email, presence: true,
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
        user_params[:session_token]=SecureRandom.base64
        validates :user_id, presence: true, length: {minimum: 6}, uniqueness: {case_sensitive: true}
        
        validates :user_cell, presence: true, length: {minimum: 10}
        #validates :password, presence: true, length: {minimum: 6}
        #validates :password_confirmation, presence: true
        for i in 0..2
            user_params["source_"+(i+1).to_s]=i
        end
        #User.create! user_params
        @user = User.new user_params
        if @user.save
            return @user
        else
            return nil
        end
    end
    
    def update_rankings(rankings)
        self.update_attributes!(source_1: rankings[0], source_2: rankings[1], source_3: rankings[2])
    end
    
    def update_ratings(ratings)
        self.update_attributes!(darksky: ratings["darksky"], weatherunderground: ratings["weatherunderground"], openweathermap: ratings["openweathermap"]) 
    end
    
end