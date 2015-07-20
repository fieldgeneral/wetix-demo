class EventOwnersController < ApplicationController
  before_action :set_event_owner, only: [:show, :edit, :update, :destroy]

  # GET /event_owners
  # GET /event_owners.json
  def index
    if current_user.nil?
      redirect_to root_path
    end
    @events = EventOwner.all
  end

  # GET /event_owners/1
  # GET /event_owners/1.json
  def show
    require 'uri'
    @event = EventOwner.find(params[:id])
    @is_admin = current_user && current_user.id == @event.id
  end

  # GET /event_owners/new
  def new
    if current_user
      redirect_to root_path, :notice => "You are already registered."
    end
      @event = EventOwner.new
  end

  # GET /event_owners/1/edit
  def edit
    @event = EventOwner.find(params[:id])
    if current_user.id != @event.id
      redirect_to @event
    end
  end

  # POST /event_owners
  # POST /event_owners.json
  def create
    @event = EventOwner.new(event_owner_params)

    respond_to do |format|
      if @event.save
        session[:event_owner_id] = @event.id
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /event_owners/1
  # PATCH/PUT /event_owners/1.json
  def update
    respond_to do |format|
      if @event.update_attributes(event_owner_params)
        format.html { redirect_to @event, notice: 'Event successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_owners/1
  # DELETE /event_owners/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to event_owners_url, notice: 'Event owner was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /event_owners/oauth/1
def oauth
  if !params[:code]
    return redirect_to('/')
  end

  redirect_uri = url_for(:controller => 'event_owners', :action => 'oauth', :event_owner_id => params[:event_owner_id], :host => request.host_with_port)
  @event = EventOwner.find(params[:event_owner_id])
  begin
    @event.request_wepay_access_token(params[:code], redirect_uri)
  rescue Exception => e
    error = e.message
  end

  if error
    redirect_to @event, alert: error
  else
    redirect_to @event, notice: 'We successfully connected you to WePay!'
  end
end

# GET /event_owners/buy/1
def buy
  redirect_uri = url_for(:controller => 'event_owners', :action => 'payment_success', :event_owner_id => params[:event_owner_id], :host => request.host_with_port)
  @event = EventOwner.find(params[:event_owner_id])
  begin
    @checkout = @event.create_checkout(redirect_uri)
  rescue Exception => e
    redirect_to @event, alert: e.message
  end
end

def buy_custom
  @event = EventOwner.find(params[:event_owner_id])
  begin
    @checkout = @event.create_checkout_custom(params[:credit_card_id])
  rescue Exception => e
    redirect_to @event, alert: e.message
  end
end

# GET /event_owners/payment_success/1
def payment_success
  @event = EventOwner.find(params[:event_owner_id])
  if !params[:checkout_id]
    return redirect_to @event, alert: "Error - Checkout ID is expected"
  end
  if (params['error'] && params['error_description'])
    return redirect_to @event, alert: "Error - #{params['error_description']}"
  end
  redirect_to @event, notice: "Thanks for the payment! You should receive a confirmation email shortly."
end

##################### Custom User Creation ###############

def new_custom
  if current_user
    redirect_to root_path, :notice => "You are already registered."
  end
    @event = EventOwner.new
end

def custom_user
  require 'wepay'
  @event = EventOwner.new(event_owner_params)

  response = WEPAY.call('/user/register', false, {
    :client_id       => CLIENT_ID,
    :client_secret   => CLIENT_SECRET,
    :email           => @event.email,
    :scope           => 'manage_accounts,view_balance,collect_payments,view_user',
    :first_name      => @event.name.gsub(/\s+/m, ' ').strip.split(" ").first,
    :last_name       => @event.name.gsub(/\s+/m, ' ').strip.split(" ").second,
    :redirect_uri    => "http://localhost:3000/event_owners",
    :original_ip     => request.remote_ip,
    :original_device => request.env['HTTP_USER_AGENT'],
    :tos_acceptance_time => Time.now.to_i
    })

    @access_token = response['access_token']

    response = WEPAY.call('/account/create', @access_token, {
      :name        =>  @event.name,
      :description =>  @event.description
      })

    @event.update_attributes(:wepay_account_id => response['account_id'], :wepay_access_token => @access_token)

    respond_to do |format|
      if @event.wepay_account_id && @event.save
        response = WEPAY.call('/user/send/confirmation', @access_token, {})
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new_custom }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
end

private
    # Use callbacks to share common setup or constraints between actions.
    def set_event_owner
      @event = EventOwner.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_owner_params
      params.require(:event_owner).permit(:name, :email, :password, :event_name, :attendee_list, :description, :from_event, :to_event, :location, :ticket_price, :wepay_access_token, :wepay_account_id)
    end
end
