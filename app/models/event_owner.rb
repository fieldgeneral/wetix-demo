class EventOwner < ActiveRecord::Base

  validates :password, :presence => true
  validates :password, :length => { :in => 6..200}
  validates :name, :email, :presence => true
  validates :email, :uniqueness => { :case_sensitive => false }
  validates :email, :format => { :with => /@/, :message => " is invalid" }

  serialize :attendee_list, Array

  def password
    password_hash ? @password ||= BCrypt::Password.new(password_hash) : nil
  end

  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.password_hash = @password
  end

  def self.authenticate(email, test_password)
    event_owner = EventOwner.find_by_email(email)
    if event_owner && event_owner.password == test_password
      event_owner
    else
      nil
    end
  end

  def wepay_authorization_url(redirect_uri)
    WEPAY.oauth2_authorize_url(redirect_uri, self.email, self.name)
  end

# takes a code returned by wepay oauth2 authorization and makes an api call to generate oauth2 token for this event owner.
def request_wepay_access_token(code, redirect_uri)
  response = WEPAY.oauth2_token(code, redirect_uri)
  if response['error']
    raise "Error - "+ response['error_description']
  elsif !response['access_token']
    raise "Error requesting access from WePay"
  else
    self.wepay_access_token = response['access_token']
    self.save
  end
end

def has_wepay_access_token?
  !self.wepay_access_token.nil?
end

# makes an api call to WePay to check if current access token for event owner is still valid
def has_valid_wepay_access_token?
  if self.wepay_access_token.nil?
    return false
  end
  response = WEPAY.call("/user", self.wepay_access_token)
  response && response["user_id"] ? true : false
end

# takes a code returned by wepay oauth2 authorization and makes an api call to generate oauth2 token for this event owner.
def request_wepay_access_token(code, redirect_uri)
  response = WEPAY.oauth2_token(code, redirect_uri)
  if response['error']
    raise "Error - "+ response['error_description']
  elsif !response['access_token']
    raise "Error requesting access from WePay"
  else
    self.wepay_access_token = response['access_token']
    self.save

	#create WePay account
    self.create_wepay_account
  end
end


def has_wepay_account?
  self.wepay_account_id != 0 && !self.wepay_account_id.nil?
end

# creates a WePay account for this event owner with the event's name
def create_wepay_account
  if self.has_wepay_access_token? && !self.has_wepay_account?
    params = { :name => self.name, :description => self.description }
    response = WEPAY.call("/account/create", self.wepay_access_token, params)

    if response["account_id"]
      self.wepay_account_id = response["account_id"]
      return self.save
    else
      raise "Error - " + response["error_description"]
    end

  end
raise "Error - cannot create WePay account"
end

# creates a checkout object using WePay API for this farmer
def create_checkout(redirect_uri)
  # calculate app_fee as 10% of produce price
  app_fee = self.ticket_price * 0.1

  params = {
    :account_id => self.wepay_account_id,
    :short_description => "Ticket for #{self.event_name}",
    :type => :GOODS,
    :amount => self.ticket_price,
    :app_fee => app_fee,
    :fee_payer => :payee,
    :mode => :iframe,
    :redirect_uri => redirect_uri
  }
  response = WEPAY.call('/checkout/create', self.wepay_access_token, params)

  if !response
    raise "Error - no response from WePay"
  elsif response['error']
    raise "Error - " + response["error_description"]
  end

  return response
  self.attendee_list += [params["nameOnCard"]]
end

def create_checkout_custom(credit_card_id)
  WEPAY.call('/checkout/create', self.wepay_access_token, {
    :account_id             => self.wepay_account_id,
    :amount                 => self.ticket_price,
    :short_description      => "Ticket for #{self.event_name}",
    :type                   => 'GOODS',
    :payment_method_id      => credit_card_id, # the user's credit_card_id
    :payment_method_type    => 'credit_card'
  })

  if !response
    raise "Error - no response from WePay"
  elsif response['error']
    raise "Error - " + response["error_description"]
  end

  return response

  if (params['error'] && params['error_description'])
    return redirect_to @event, alert: "Error - #{params['error_description']}"
  else
    redirect_to @event, notice: "Thanks for the payment! You should receive a confirmation email shortly."
  end
end

end
