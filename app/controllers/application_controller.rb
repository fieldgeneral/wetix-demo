class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user

private
def current_user
  @current_user ||= EventOwner.find(session[:event_owner_id]) if session[:event_owner_id]
rescue ActiveRecord::RecordNotFound
    session[:event_owner_id] = nil
end
end