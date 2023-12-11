class AddProcessorIdsToPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :plans, :stripe_id, :string
    add_column :plans, :braintree_id, :string
    add_column :plans, :paddle_billing_id, :string
    add_column :plans, :paddle_classic_id, :string
    add_column :plans, :lemon_squeezy_id, :string
    add_column :plans, :fake_processor_id, :string

    Plan.find_each do |plan|
      plan.update(
        stripe_id: plan.details&.dig("stripe_id"),
        braintree_id: plan.details&.dig("braintree_id"),
        paddle_billing_id: plan.details&.dig("paddle_billing_id"),
        paddle_classic_id: plan.details&.dig("paddle_id") || plan.details&.dig("paddle_classic_id"),
        fake_processor_id: plan.details&.dig("fake_processor_id")
      )
    end
  end
end
