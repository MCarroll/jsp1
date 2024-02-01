class Account < ApplicationRecord
  has_prefix_id :acct

  include Account::Billing
  include Account::Domains
  include Account::Transfer

  belongs_to :owner, class_name: "User"
  has_many :account_invitations, dependent: :destroy
  has_many :account_users, dependent: :destroy
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :account_notifications, dependent: :destroy, class_name: "Noticed::Event"
  has_many :users, through: :account_users
  has_many :addresses, as: :addressable, dependent: :destroy

  scope :personal, -> { where(personal: true) }
  scope :team, -> { where(personal: false) }
  scope :sorted, -> { order(personal: :desc, name: :asc) }

  has_one_attached :avatar

  validates :avatar, resizable_image: true
  validates :name, presence: true

  def team?
    !personal?
  end

  def personal_account_for?(user)
    personal? && owner?(user)
  end

  def owner?(user)
    owner_id == user.id
  end
end
