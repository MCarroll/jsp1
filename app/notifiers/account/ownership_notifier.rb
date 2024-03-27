class Account::OwnershipNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = "Noticed::NotificationChannel"
    config.stream = -> { recipient }
    config.message = :to_websocket
  end

  def previous_owner
    record || params[:previous_owner] || User.new(name: "Someone")
  end

  def message
    t "notifications.account_transferred", previous_owner: previous_owner.name, account: account.name
  end

  def url
    account_path(account)
  end
end
