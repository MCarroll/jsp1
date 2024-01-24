# Configures Noticed to be scoped by account

module EventExtension
  extend ActiveSupport::Concern

  included do
    belongs_to :account
  end

  class_methods do
    # Set account association from params
    def with(params)
      account = params.delete(:account) || Current.account
      record = params.delete(:record)

      # Instantiate Noticed::Event with account:belongs_to
      new(account: account, params: params, record: record)
    end
  end

  def recipient_attributes_for(recipient)
    super.merge(account_id: account&.id || recipient.personal_account&.id)
  end
end

module NotificationExtension
  extend ActiveSupport::Concern

  included do
    belongs_to :account
    delegate :message, to: :event
  end
end

Rails.configuration.to_prepare do
  Noticed::Event.include EventExtension
  Noticed::Notification.include NotificationExtension
end
