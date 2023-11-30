class User < ApplicationRecord
  include User::Accounts
  include User::Agreements
  include User::Authenticatable
  include User::Mentions
  include User::Searchable
  include User::Theme

  has_many :api_tokens, dependent: :destroy
  has_many :connected_accounts, as: :owner, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :notification_tokens, dependent: :destroy

  has_noticed_notifications
  has_one_attached :avatar
  has_person_name

  validates :avatar, resizable_image: true
  validates :name, presence: true
end
