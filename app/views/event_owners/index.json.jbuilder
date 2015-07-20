json.array!(@events) do |event_owner|
  json.extract! event_owner, :id, :name, :email, :password_hash, :event_name, :description, :ticket_price, :wepay_access_token, :wepay_account_id
  json.url event_owner_url(event_owner, format: :json)
end
