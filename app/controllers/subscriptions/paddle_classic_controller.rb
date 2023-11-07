class Subscriptions::PaddleClassicController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_account_admin

  def show
    current_account.set_payment_processor :paddle_classic, processor_id: params[:user_id]
    @subscription = Pay::PaddleClassic::Subscription.sync(params[:subscription_id])

    if @subscription.active?
      redirect_to root_path, notice: t("subscriptions.created")
    else
      redirect_to root_path, alert: t("something_went_wrong")
    end
  end
end
