class LandingController < ApplicationController
  def index
    if current_user
      redirect_to event_owners_path
    end
  end
end
