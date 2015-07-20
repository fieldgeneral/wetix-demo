class SessionsController < ApplicationController
  # GET /sessions/new
  def new
  end

  # POST /sessions
  def create
    event_owner = EventOwner.authenticate params[:email], params[:password]
      if event_owner
        session[:event_owner_id] = event_owner.id
        redirect_to "/event_owners", :notice => "Welcome back to WeTix"
      else
        redirect_to :login, :alert => "Invalid email or password"
      end
  end

  def destroy
    session[:event_owner_id] = nil
    redirect_to root_path :notice => "You have been logged out"
  end
end
