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
    has_prefix_id :sub
    delegate :currency, to: :plan
  end

  def plan
    @plan ||= Plan.where("#{customer.processor}_id": processor_plan).first
  end

  def amount
    (quantity == 0) ? plan.amount : plan.amount * quantity
  end
end

module ChargeExtensions
  extend ActiveSupport::Concern

  included do
    has_prefix_id :ch
    after_create :complete_referral, if: -> { defined?(Refer) }
  end

  # Mark the account owner's referral complete on the first successful payment
  def complete_referral
    customer.owner.owner.referral&.complete!
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
