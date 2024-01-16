require "test_helper"

class ApplicationNotifierTest < ActiveSupport::TestCase
  test "cleans up iOS device tokens" do
    assert_difference "NotificationToken.count", -1 do
      ApplicationNotifier.new.cleanup_device_token(
        token: notification_tokens(:ios).token,
        platform: "iOS"
      )
    end
  end

  test "cleans up FCM Android device tokens" do
    assert_difference "NotificationToken.count", -1 do
      ApplicationNotifier.new.cleanup_device_token(
        token: notification_tokens(:android).token,
        platform: "fcm"
      )
    end
  end
end
