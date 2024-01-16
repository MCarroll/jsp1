require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "notifications with user param are destroyed when user destroyed" do
    user = users(:one)
    Account::AcceptedInviteNotifier.with(user: user, account: accounts(:one)).deliver(users(:two))

    assert_difference "Noticed::Notification.count", -1 do
      user.destroy
    end
  end

  test "notifications with account are destroyed when account destroyed" do
    account = accounts(:one)
    Account::OwnershipNotifier.with(previous_owner: users(:one), account: account).deliver(users(:two))

    assert_difference "Noticed::Notification.count", -1 do
      account.destroy
    end
  end
end
