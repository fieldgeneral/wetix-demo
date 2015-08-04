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

###### Check for KYC ######

def kyc_check
  @account = EventOwner.find(current_user.id)
  response = WEPAY.call('/account', @account.wepay_access_token, {
    :account_id => @account.wepay_account_id
    })

    response['action_reasons'].to_s
end

def kyc_account
  @account = EventOwner.find(current_user.id)
  kyc = WEPAY.call('/account/get_update_uri', @account.wepay_access_token, {
    :account_id   => @account.wepay_account_id,
    :mode         => "iframe",
    :prefill_info => {
      :name  => @account.name,
      :email => @account.email
    }
    })
end

helper_method :kyc_check
helper_method :kyc_account

end
