require 'test_helper'

class MovieControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get movie_index_url
    assert_response :success
  end

end
