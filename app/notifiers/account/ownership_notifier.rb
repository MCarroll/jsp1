class Account::OwnershipNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = "Noticed::NotificationChannel"
    config.stream = -> { recipient }
    config.message = :to_websocket
  end

  required_params :previous_owner

  def to_websocketa(notification)
    {
      account_id: notification.account_id,
      html: ApplicationController.render(partial: "notifications/notification", locals: {notification: notification})
    }
  end

  def message
    t "notifications.account_transferred", previous_owner: params[:previous_owner].name, account: account.name
  end

  def url
    account_path(account)
  end
end
