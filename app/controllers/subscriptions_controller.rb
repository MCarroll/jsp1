class SubscriptionsController < ApplicationController
  before_action :require_payments_enabled
  before_action :authenticate_user_with_sign_up!
  before_action :require_account
  before_action :require_current_account_admin, except: [:show]
  before_action :set_plan, only: [:new, :create, :update]
  before_action :set_subscription, only: [:show, :edit, :update]
  before_action :redirect_if_already_subscribed, only: [:new]
  before_action :handle_past_due_or_unpaid, only: [:new]

  layout "checkout", only: [:new, :create]

  def index
    @payment_processor = current_account.payment_processor
    @subscriptions = current_account.subscriptions.active.or(current_account.subscriptions.past_due).or(current_account.subscriptions.unpaid).order(created_at: :asc).includes([:customer])
  end

  def show
    redirect_to edit_subscription_path(@subscription)
  end

  def new
    set_checkout_session if Jumpstart.config.stripe?
  rescue Pay::Error => e
    flash[:alert] = e.message
    redirect_to pricing_path
  end

  # Only used by Braintree
  def create
    payment_processor = params[:processor] ? current_account.set_payment_processor(params[:processor]) : current_account.payment_processor
    payment_processor.payment_method_token = params[:payment_method_token]
    args = {
      plan: @plan.id_for_processor(payment_processor.processor),
      trial_period_days: @plan.trial_period_days
    }
    args[:quantity] = current_account.per_unit_quantity if @plan.charge_per_unit?
    payment_processor.subscribe(**args)
    redirect_to root_path, notice: t(".created")
  rescue Pay::ActionRequired => e
    redirect_to pay.payment_path(e.payment.id)
  rescue Pay::Error => e
    flash[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  def edit
    # Include current plan even if hidden
    @current_plan = @subscription.plan

    plans = Plan.visible.sorted.or(Plan.where(id: @current_plan.id))
    @monthly_plans, @yearly_plans = plans.partition(&:monthly?)
  end

  def update
    @subscription.swap @plan.id_for_processor(current_account.payment_processor.processor)
    redirect_to subscriptions_path, notice: t(".success")
  rescue Pay::ActionRequired => e
    redirect_to pay.payment_path(e.payment.id)
  rescue Pay::Error => e
    edit # Reload plans
    flash[:alert] = e.message
    render :edit, status: :unprocessable_entity
  end

  def billing_settings
    current_account.update(billing_params)
    redirect_to subscriptions_path, notice: t(".billing_settings_updated")
  end

  private

  def billing_params
    params.require(:account).permit(:extra_billing_info, :billing_email)
  end

  def require_payments_enabled
    return if Jumpstart.config.payments_enabled?
    redirect_back_or_to root_path, alert: "Jumpstart must be configured for payments before you can manage subscriptions."
  end

  # Pricing page will only display visible plans, but hidden plans are included here to make customer support easier.
  def set_plan
    @plan = Plan.find_by_prefix_id!(params[:plan])
  rescue ActiveRecord::RecordNotFound
    redirect_to pricing_path
  end

  def set_subscription
    @subscription = current_account.subscriptions.find_by_prefix_id(params[:id])
    redirect_to subscriptions_path if @subscription.nil?
  end

  def redirect_if_already_subscribed
    if current_account.payment_processor&.subscribed?
      redirect_to subscriptions_path, alert: t(".already_subscribed")
    end
  end

  def handle_past_due_or_unpaid
    if (subscription = current_account.payment_processor&.subscription) && (subscription.past_due? || subscription.unpaid?)
      redirect_to subscriptions_path
    end
  end

  def set_checkout_session
    payment_processor = current_account.set_payment_processor(:stripe)

    # Only allow trials on the account's first subscription
    trial_allowed = current_account.subscriptions.none?

    subscription_data = {
      metadata: params.fetch(:metadata, {}).permit!.to_h,
      trial_settings: {end_behavior: {missing_payment_method: "pause"}},
      trial_period_days: ((@plan.trial_period_days.to_i > 1 && trial_allowed) ? @plan.trial_period_days : nil)
    }.compact
    args = {
      allow_promotion_codes: true,
      automatic_tax: {enabled: @plan.taxed?},
      consent_collection: {terms_of_service: :required},
      customer_update: {address: :auto},
      mode: :subscription,
      line_items: @plan.id_for_processor(:stripe),
      payment_method_collection: :if_required,
      return_url: subscriptions_stripe_url(return_to: params[:return_to]),
      subscription_data: subscription_data,
      ui_mode: :embedded
    }
    args[:quantity] = current_account.per_unit_quantity if @plan.charge_per_unit?
    @checkout_session = payment_processor.checkout(**args)
  end
end
