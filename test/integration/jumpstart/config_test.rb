require "test_helper"

class Jumpstart::ConfigTest < ActionDispatch::IntegrationTest
  test "can access jumpstart config" do
    get "/jumpstart"
    assert_response :success
  end
end
