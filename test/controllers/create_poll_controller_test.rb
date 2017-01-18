require 'test_helper'

class CreatePollControllerTest < ActionController::TestCase
  test "should get close_poll" do
    get :close_poll
    assert_response :success
  end

  test "should get vote" do
    get :vote
    assert_response :success
  end

  test "should get see_candidates" do
    get :see_candidates
    assert_response :success
  end

  test "should get see_standings" do
    get :see_standings
    assert_response :success
  end

end
