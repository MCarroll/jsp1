module SubscriptionsHelper
  def pricing_cta(plan)
    plan.trial_period_days? ? t(".start_trial") : t(".get_started")
  end
end
