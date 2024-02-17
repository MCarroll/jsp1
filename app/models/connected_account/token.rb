module ConnectedAccount::Token
  extend ActiveSupport::Concern

  # Use this method to retrieve the latest access_token.
  # Token will be automatically renewed as necessary
  def token
    renew_token! if expired?
    access_token
  end

  # Tokens that expire very soon should be consider expired
  def expired?
    expires_at? && expires_at <= 30.minutes.from_now
  end

  # Force a renewal of the access token
  def renew_token!
    new_token = current_token.refresh!
    update(
      access_token: new_token.token,
      refresh_token: new_token.refresh_token,
      expires_at: Time.at(new_token.expires_at)
    )
  end

  private

  def current_token
    OAuth2::AccessToken.new(
      strategy.client,
      access_token,
      refresh_token: refresh_token
    )
  end

  def strategy
    # First check the Jumpstart providers for credentials
    provider_config = Jumpstart::Omniauth.enabled_providers[provider.to_sym]

    # Fallback to the Rails credentials
    provider_config ||= Rails.application.credentials.dig(:omniauth, provider.to_sym)

    OmniAuth::Strategies.const_get(OmniAuth::Utils.camelize(provider).to_s).new(
      nil,
      provider_config[:public_key], # client id
      provider_config[:private_key] # client secret
    )
  end
end
