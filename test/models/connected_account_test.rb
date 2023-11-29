require "test_helper"

class ConnectedAccountTest < ActiveSupport::TestCase
  test "handles access token secrets" do
    ca = ConnectedAccount.new(access_token_secret: "test")
    assert_equal "test", ca.access_token_secret
  end

  test "handles empty access token secrets" do
    assert_nothing_raised do
      ConnectedAccount.new(access_token_secret: "")
    end
  end

  test "expired if token expired in the past" do
    ca = ConnectedAccount.new(expires_at: 1.hour.ago)
    assert ca.expired?
  end

  test "expiring if token expires soon" do
    ca = ConnectedAccount.new(expires_at: 4.minutes.from_now)
    assert ca.expired?
  end

  test "not expiring if token expires in the future" do
    ca = ConnectedAccount.new(expires_at: 1.day.from_now)
    assert_not ca.expired?
  end

  test "not expiring if token has no expiration" do
    ca = ConnectedAccount.new(expires_at: nil)
    assert_not ca.expired?
  end
end
