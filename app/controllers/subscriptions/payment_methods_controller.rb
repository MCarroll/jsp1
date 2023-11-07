class Subscriptions::PaymentMethodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscription

  # Redirect or render the new payment method
  def new
    @payment_processor = @subscription.customer
    case @payment_processor.processor
    when "stripe"
      redirect_to @payment_processor.billing_portal(return_url: subscriptions_url).url, allow_other_host: true
    when "paddle_classic", "paddle_billing"
      redirect_to @subscription.paddle_update_url, allow_other_host: true
    end
  end

  def create
    payment_processor = current_account.set_payment_processor(params[:processor])
    payment_processor.update_payment_method(params[:payment_method_token])
    redirect_to subscriptions_path, notice: t(".updated")
  end

  private

  def set_subscription
    @subscription = current_account.subscriptions.find_by_prefix_id(params[:subscription_id])
  end
end
