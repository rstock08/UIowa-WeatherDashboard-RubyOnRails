class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :get_active_link
  
  def set_current_user
    @current_user||= User.find_by_session_token(session[:session_token])
  end
  
  def get_active_link
    @@controller = controller_name
  end
  
  def self.link_class(link_name)
    if (link_name==@@controller)
      return "active_header_link"
    else
      return "header_link"
    end
  end
end
