class Account::AcceptedInviteNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = "NotificationChannel"
    config.stream = -> { recipient }
    config.message = :to_websocket
  end

  required_params :user

  def to_websocket
    {
      account_id: record.account_id,
      html: ApplicationController.render(partial: "notifications/notification", locals: {notification: record})
    }
  end

  def message
    t "notifications.invite_accepted", user: params[:user].name
  end

  def url
    account_path(account)
  end
end
