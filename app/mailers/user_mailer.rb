class UserMailer < ApplicationMailer
    default from: "xxx"
    
    def sample_email(email, password)
        @password = password
        mail(to: email, subject: 'Password Reset')
    end
    
    def signup_email(email)
        mail(to: email, subject: 'Sign Up Confirmed')
    end
    
    def notification(email, weather)
        @hours=[]
        @days=[]
        @weather = weather
        if weather[0]["daily"]
            @days=@weather[0]["daily"].keys
        end
        if weather[0]["hourly"]
            @hours=@weather[0]["hourly"].keys
        end
        mail(to: email, subject: 'Weather Dashboard Notification')
    end
    
    def text_notification(cell, weather)
        number_to_send_to = "+1#{cell}"
        
        twilio_sid = "xxx" # For simplicity left these not as environmental variables!!!
        twilio_token = "xxx"
        twilio_phone_number = "xxx"
        @client = Twilio::REST::Client.new(twilio_sid, twilio_token)
        
        @client.messages.create(
            :from => twilio_phone_number,
            :to => number_to_send_to,
            :body => "Weather Dashboard " + weather
            )
    end
    
    def welcome_text(user_id, cell)
        number_to_send_to =  "+1#{cell}"
        
        twilio_sid = "xxx" # For simplicity left these not as environmental variables!!!
        twilio_token = "xxx"
        twilio_phone_number = "xxx"
        @client = Twilio::REST::Client.new(twilio_sid, twilio_token)
        
        @client.messages.create(
            :from => twilio_phone_number,
            :to => number_to_send_to,
            :body => "Welcome " + user_id + " to Weather Dashboard"
            )
    end
end
