class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validates :address_type, :line1, :city, :postal_code, :country, presence: true

  enum address_type: [:billing, :shipping]

  after_commit :update_pay_customer_addresses, if: -> { billing? && addressable.respond_to?(:pay_customers) }

  def to_stripe
    {
      city: city,
      country: country,
      line1: line1,
      line2: line2,
      postal_code: postal_code,
      state: state
    }
  end

  private

  def update_pay_customer_addresses
    addressable.pay_customers.each(&:update_customer!)
  end
end
