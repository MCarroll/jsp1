module User::Authenticatable
  extend ActiveSupport::Concern

  included do
    include User::TwoFactorAuthentication

    devise(*[:database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, (:omniauthable if defined? OmniAuth)].compact)
    has_referrals if defined?(::Refer)

    has_many :api_tokens, dependent: :destroy
    has_many :connected_accounts, as: :owner, dependent: :destroy

    attr_readonly :admin
  end
end
