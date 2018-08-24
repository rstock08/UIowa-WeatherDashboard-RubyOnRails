class SessionsController < ApplicationController
    before_filter :set_current_user
    
    def session_params
        params.require(:user).permit(:user_id, :email, :session_token, :password, :new_password, :new_password_confirmation)
    end
  
    def destroy
        reset_session
        redirect_to metrics_path
    end
    
    def create
        userArr = User.where("user_id = '"+session_params[:user_id]+"'")
        user = userArr[0] unless userArr.empty?
        
        if user && user.authenticate(session_params[:password])
            session[:session_token] = user.session_token
            @user = user.user_id
            flash[:notice] = "You are logged in as #{@user}"
            redirect_to weather_locations_path
        else
            flash[:notice] = "Invalid user-id/password combination."
            redirect_to login_path
        end
    end
    
    def request_password
        userArr = User.where("email = '"+session_params[:email]+"'")
        @user = userArr[0] unless userArr.empty?
        if @user
            session[:session_token] = @user.session_token
            password = SecureRandom.hex(5)
            @user.password = password
            UserMailer.sample_email(session_params[:email], password).deliver
            flash[:notice] = "Password reset email dispatched to #{session_params[:email]}"
            @user.save!
            redirect_to login_path
        else
            flash[:warning] = "No account associated with that e-mail was found."
            redirect_to forgot_password_path
        end
    end
    
    def update_password
        userArr = User.where("email = '"+session_params[:email]+"'")
        @user = userArr[0] unless userArr.empty?
        if @user && @user.authenticate(session_params[:password])
            session[:session_token] = @user.session_token
            if session_params[:new_password] == session_params[:new_password_confirmation]
                @user.password = session_params[:new_password]
                @user.save!
                flash[:notice] = "Password has been updated."
                redirect_to weather_path
            else
                flash[:warning] = "Invalid user password."
                redirect_to change_password_path
            end
        else
            flash[:warning] = "No account associated with that e-mail/password was found."
            redirect_to change_password_path
        end
    end
    #helper_method :change_password
    
end