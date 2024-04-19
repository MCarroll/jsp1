module SubscriptionsHelper
  def pricing_cta(plan)
    plan.trial_period_days? ? t(".start_trial") : t(".get_started")
  end

  def pricing_link_to(plan, **opts)
    default_options = {class: "btn btn-secondary btn-large btn-block"}
    opts = default_options.merge(opts)

    if plan.contact_url.present?
      link_to t(".contact_us"), plan.contact_url, **opts
    else
      link_to pricing_cta(plan), new_subscription_path(plan: plan), **opts
    end
  end
end
