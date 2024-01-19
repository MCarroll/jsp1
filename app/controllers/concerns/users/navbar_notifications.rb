module Users
  module NavbarNotifications
    extend ActiveSupport::Concern

    included do
      before_action :set_notifications, if: :user_signed_in?
    end

    def set_notifications
      # Counts to send to native apps
      @account_unread = current_user.notifications.unread.where(account_id: current_account.id).count
      @total_unread = current_user.notifications.unread.where(account_id: [nil, current_account.id]).count
    end
  end
end
