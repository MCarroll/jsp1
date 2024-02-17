class ConnectedAccount < ApplicationRecord
  include Token

  serialize :auth, coder: JSON

  encrypts :access_token
  encrypts :access_token_secret

  # Associations
  belongs_to :owner, polymorphic: true

  # Helper scopes for each provider
  Devise.omniauth_configs.each do |provider, _|
    scope provider, -> { where(provider: provider) }
  end

  # Look up from Omniauth auth hash
  def self.for_auth(auth)
    where(provider: auth.provider, uid: auth.uid).first
  end

  def provider_name
    Jumpstart::Omniauth::AVAILABLE_PROVIDERS.dig(provider, :name) || provider.humanize
  end

  def name
    auth&.dig("info", "name")
  end

  def email
    auth&.dig("info", "email")
  end

  def image_url
    auth&.dig("info", "image") || GravatarHelper.gravatar_url_for(email)
  end
end
