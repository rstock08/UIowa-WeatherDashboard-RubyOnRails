class UsersController < ApplicationController

  def user_params
    params.require(:user).permit(:user_id, :email, :session_token, :password, :password_confirmation, :user_cell, :user_carrier)
  end

  def create
    if not User.where( "user_id = '"+user_params[:user_id]+"'").empty?
        flash[:notice] = "Sorry, this user-id is taken. Try again."
        redirect_to new_user_path
    elsif not User.where( "email = '"+user_params[:email]+"'").empty?
        flash[:notice] = "This e-mail address is already associated with an account."
        redirect_to new_user_path
    elsif user_params[:password] != user_params[:password_confirmation]
        flash[:notice] = "Password and password confirmation do not match."
        redirect_to new_user_path
    else
        @user = User.create_user! user_params
        if @user
          UserMailer.signup_email(user_params[:email]).deliver
          #UserMailer.welcome_text(@user.user_id, @user.user_cell).deliver
          flash[:notice] = "Welcome #{@user.user_id}. Your account has been created"
          redirect_to login_path
        else
          render 'new'
        end
    end
  end

end
