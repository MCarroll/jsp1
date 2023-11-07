class Subscriptions::StripeController < ApplicationController
  # Handles Stripe Checkout callback

  before_action :authenticate_user!

  def show
    @subscription = Pay::Stripe::Subscription.sync_from_checkout_session(params[:session_id])

    if @subscription.active?
      flash[:notice] = t("subscriptions.created")
    else
      flash[:alert] = t("something_went_wrong")
    end

    redirect_to params.fetch(:return_to, root_path)
  end
end
