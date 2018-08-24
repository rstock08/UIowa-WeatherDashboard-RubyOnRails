class UserMailer < ApplicationMailer
    default from: "fose.team1@gmail.com"
    
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
        
        twilio_sid = "AC1a6dc75e16b19ec6bb91125bfd25fbcf" # For simplicity left these not as environmental variables!!!
        twilio_token = "c485d958cf0dc14f3745d9594626c811"
        twilio_phone_number = "+15635945927"
        @client = Twilio::REST::Client.new(twilio_sid, twilio_token)
        
        @client.messages.create(
            :from => twilio_phone_number,
            :to => number_to_send_to,
            :body => "Weather Dashboard " + weather
            )
    end
    
    def welcome_text(user_id, cell)
        number_to_send_to =  "+1#{cell}"
        
        twilio_sid = "AC1a6dc75e16b19ec6bb91125bfd25fbcf" # For simplicity left these not as environmental variables!!!
        twilio_token = "c485d958cf0dc14f3745d9594626c811"
        twilio_phone_number = "+15635945927"
        @client = Twilio::REST::Client.new(twilio_sid, twilio_token)
        
        @client.messages.create(
            :from => twilio_phone_number,
            :to => number_to_send_to,
            :body => "Welcome " + user_id + " to Weather Dashboard"
            )
    end
end
