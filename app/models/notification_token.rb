class NotificationToken < ApplicationRecord
  # Tokens for sending push notifications to mobile devices

  belongs_to :user
  validates :token, presence: true
  validates :platform, presence: true, inclusion: {in: %w[iOS Android]}

  scope :android, -> { where(platform: "Android") }
  scope :ios, -> { where(platform: "iOS") }
end
