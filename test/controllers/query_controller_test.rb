require 'test_helper'

class QueryControllerTest < ActionController::TestCase
  test "should get election_year" do
    get :election_year
    assert_response :success
  end

  test "should get presidential_candidates" do
    get :presidential_candidates
    assert_response :success
  end

end
