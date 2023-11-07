class Subscriptions::PaddleBillingController < ApplicationController
  before_action :authenticate_user!, only: :show
  before_action :require_current_account_admin, only: :show

  def show
    current_account.set_payment_processor :paddle_billing, processor_id: params[:user_id]
    @subscription = Pay::PaddleBilling::Subscription.sync_from_transaction(params[:transaction_id])

    if @subscription.active?
      redirect_to root_path, notice: t("subscriptions.created")
    else
      redirect_to root_path, alert: t("something_went_wrong")
    end
  end

  # Paddle update / cancel renders here
  def edit
  end
end
