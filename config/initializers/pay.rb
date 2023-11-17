Pay.setup do |config|
  config.application_name = Jumpstart.config.application_name
  config.business_name = Jumpstart.config.business_name
  config.business_address = Jumpstart.config.business_address
  config.support_email = Jumpstart.config.support_email

  config.routes_path = "/"

  config.mail_to = -> {
    pay_customer = params[:pay_customer]
    account = pay_customer.owner

    recipients = [ActionMailer::Base.email_address_with_name(pay_customer.email, pay_customer.customer_name)]
    recipients << account.billing_email if account.billing_email?
    recipients
  }
end

module SubscriptionExtensions
  extend ActiveSupport::Concern

  included do
    # Generates hash IDs with a friendly prefix so users can't guess hidden plan IDs on checkout
    # https://github.com/excid3/prefixed_ids
    has_prefix_id :sub
  end

  def plan
    @plan ||= Plan.where("details @> ?", {"#{customer.processor}_id": processor_plan}.to_json).first
  end

  def plan_interval
    plan.interval
  end

  def amount_with_currency(**)
    total = (quantity == 0) ? plan.amount : plan.amount * quantity
    Pay::Currency.format(total, currency: plan.currency, **)
  end
end

module ChargeExtensions
  extend ActiveSupport::Concern

  included do
    # Generates hash IDs with a friendly prefix so users can't guess hidden plan IDs on checkout
    # https://github.com/excid3/prefixed_ids
    has_prefix_id :ch
  end
end

Rails.configuration.to_prepare do
  Pay::Subscription.include SubscriptionExtensions
  Pay::Charge.include ChargeExtensions

  # Use Inter font for full UTF-8 support in PDFs
  # https://github.com/rsms/inter
  Receipts.default_font = {
    bold: Rails.root.join("app/assets/fonts/Inter-Bold.ttf"),
    normal: Rails.root.join("app/assets/fonts/Inter-Regular.ttf")
  }
end
