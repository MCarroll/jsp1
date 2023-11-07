class UpgradeToPayV7 < ActiveRecord::Migration[7.1]
  def change
    add_column :pay_subscriptions, :payment_method_id, :string
    add_column :pay_customers, :stripe_account, :string
    add_column :pay_payment_methods, :stripe_account, :string
    add_column :pay_subscriptions, :stripe_account, :string
    add_column :pay_charges, :stripe_account, :string

    Pay::Customer.where(processor: :paddle).update_all(processor: :paddle_classic)

    Pay::Customer.find_each { |c| c.update(stripe_account: c.data&.dig("stripe_account")) }
    Pay::Subscription.find_each { |c| c.update(stripe_account: c.data&.dig("stripe_account")) }
    Pay::PaymentMethod.find_each { |c| c.update(stripe_account: c.data&.dig("stripe_account")) }
    Pay::Charge.find_each { |c| c.update(stripe_account: c.data&.dig("stripe_account")) }

    Plan.find_each { |c| c.update(paddle_classic_id: c.details&.dig("paddle_id")) }
  end
end
