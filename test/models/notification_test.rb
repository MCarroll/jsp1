require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    Notification.delete_all
  end

  test "notifications with user param are destroyed when user destroyed" do
    user = users(:one)
    AcceptedInvite.with(user: user, account: accounts(:one)).deliver(users(:two))

    assert_difference "Notification.count", -1 do
      user.destroy
    end
  end

  test "notifications with account are destroyed when account destroyed" do
    account = accounts(:one)
    AcceptedInvite.with(user: users(:one), account: account).deliver(users(:two))

    assert_difference "Notification.count", -1 do
      account.destroy
    end
  end
end
