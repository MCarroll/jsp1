module Users
  module NavbarNotifications
    extend ActiveSupport::Concern

    included do
      before_action :set_notification_counts, if: :user_signed_in?
    end

    def set_notification_counts
      @notification_counts = current_user.notifications.unread.group(:account_id).count
    end
  end
end
