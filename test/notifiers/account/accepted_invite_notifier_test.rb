require "test_helper"

class AcceptedInviteNotifierTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:company)
    @user = users(:invited)

    Account::AcceptedInviteNotifier.with(account: @account, record: @user).save!
  end

  test "notification is deleted when account is deleted" do
    assert_difference "Account::AcceptedInviteNotifier.count", -1 do
      @account.destroy
    end
  end

  test "notification is deleted when user is deleted" do
    assert_difference "Account::AcceptedInviteNotifier.count", -1 do
      @user.destroy
    end
  end
end
