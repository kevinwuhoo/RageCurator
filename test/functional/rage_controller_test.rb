require 'test_helper'

class RageControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get add" do
    get :add
    assert_response :success
  end

  test "should get queue" do
    get :queue
    assert_response :success
  end

  test "should get scrape" do
    get :scrape
    assert_response :success
  end

end
