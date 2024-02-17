module User::Authenticatable
  extend ActiveSupport::Concern

  included do
    include User::TwoFactorAuthentication

    # Include default devise modules. Others available are:
    # :lockable, :timeoutable, and :trackable
    devise(*[:database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, (:omniauthable if defined? OmniAuth)].compact)

    has_many :api_tokens, dependent: :destroy
    has_many :connected_accounts, as: :owner, dependent: :destroy

    # Protect admin flag from editing
    attr_readonly :admin

    # Uncomment to only confirm when email changes
    # before_create :skip_confirmation!
  end
end
