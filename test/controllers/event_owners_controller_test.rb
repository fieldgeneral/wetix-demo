require 'test_helper'

class EventOwnersControllerTest < ActionController::TestCase
  setup do
    @event_owner = event_owners(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:event_owners)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event_owner" do
    assert_difference('EventOwner.count') do
      post :create, event_owner: { description: @event_owner.description, email: @event_owner.email, event_name: @event_owner.event_name, name: @event_owner.name, password_hash: @event_owner.password_hash, ticket_price: @event_owner.ticket_price, wepay_access_token: @event_owner.wepay_access_token, wepay_account_id: @event_owner.wepay_account_id }
    end

    assert_redirected_to event_owner_path(assigns(:event_owner))
  end

  test "should show event_owner" do
    get :show, id: @event_owner
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event_owner
    assert_response :success
  end

  test "should update event_owner" do
    patch :update, id: @event_owner, event_owner: { description: @event_owner.description, email: @event_owner.email, event_name: @event_owner.event_name, name: @event_owner.name, password_hash: @event_owner.password_hash, ticket_price: @event_owner.ticket_price, wepay_access_token: @event_owner.wepay_access_token, wepay_account_id: @event_owner.wepay_account_id }
    assert_redirected_to event_owner_path(assigns(:event_owner))
  end

  test "should destroy event_owner" do
    assert_difference('EventOwner.count', -1) do
      delete :destroy, id: @event_owner
    end

    assert_redirected_to event_owners_path
  end
end
