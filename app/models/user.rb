class User < ApplicationRecord
  has_prefix_id :user

  include User::Accounts
  include User::Agreements
  include User::Authenticatable
  include User::Mentions
  include User::Notifiable
  include User::Searchable
  include User::Theme

  has_many :api_tokens, dependent: :destroy
  has_many :connected_accounts, as: :owner, dependent: :destroy

  has_one_attached :avatar
  has_person_name

  validates :avatar, resizable_image: true
  validates :name, presence: true
end
