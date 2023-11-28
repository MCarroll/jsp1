class Account < ApplicationRecord
  RESERVED_DOMAINS = [Jumpstart.config.domain]
  RESERVED_SUBDOMAINS = %w[app help support]

  belongs_to :owner, class_name: "User"
  has_many :account_invitations, dependent: :destroy
  has_many :account_users, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :users, through: :account_users
  has_many :addresses, as: :addressable, dependent: :destroy
  has_one :billing_address, -> { where(address_type: :billing) }, class_name: "Address", as: :addressable
  has_one :shipping_address, -> { where(address_type: :shipping) }, class_name: "Address", as: :addressable

  scope :personal, -> { where(personal: true) }
  scope :impersonal, -> { where(personal: false) }
  scope :sorted, -> { order(personal: :desc, name: :asc) }

  has_noticed_notifications
  has_one_attached :avatar
  pay_customer stripe_attributes: :stripe_attributes

  validates :avatar, resizable_image: true
  validates :name, presence: true

  # To require a domain or subdomain, add the presence validation
  validates :domain, exclusion: {in: RESERVED_DOMAINS, message: :reserved}, uniqueness: {allow_blank: true}
  validates :subdomain, exclusion: {in: RESERVED_SUBDOMAINS, message: :reserved}, format: {with: /\A[a-zA-Z0-9]+[a-zA-Z0-9\-_]*[a-zA-Z0-9]+\Z/, message: :format, allow_blank: true}, uniqueness: {allow_blank: true}

  def find_or_build_billing_address
    billing_address || build_billing_address
  end

  # Email address used for Pay customers and receipts
  # Defaults to billing_email if defined, otherwise uses the account owner's email
  def email
    billing_email? ? billing_email : owner.email
  end

  def impersonal?
    !personal?
  end

  def personal_account_for?(user)
    personal? && owner_id == user.id
  end

  def owner?(user)
    owner_id == user.id
  end

  # An account can be transferred by the owner if it:
  # * Isn't a personal account
  # * Has more than one user in it
  def can_transfer?(user)
    impersonal? && owner?(user) && users.size >= 2
  end

  # Transfers ownership of the account to a user
  # The new owner is automatically granted admin access to allow editing of the account
  # Previous owner roles are unchanged
  def transfer_ownership(user_id)
    previous_owner = owner
    account_user = account_users.find_by!(user_id: user_id)
    user = account_user.user

    ApplicationRecord.transaction do
      account_user.update!(admin: true)
      update!(owner: user)

      # Add any additional logic for updating records here
    end

    # Notify the new owner of the change
    Account::OwnershipNotification.with(account: self, previous_owner: previous_owner).deliver_later(user)
  rescue
    false
  end

  # Used for per-unit subscriptions on create and update
  # Returns the quantity that should be on the subscription
  def per_unit_quantity
    account_users_count
  end

  private

  # Attributes to sync to the Stripe Customer
  def stripe_attributes(*args)
    {address: billing_address&.to_stripe}.compact
  end
end
