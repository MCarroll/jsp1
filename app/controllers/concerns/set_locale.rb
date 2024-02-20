# Check out the Rails guides for setting locale by domain or subdomain
# https://guides.rubyonrails.org/i18n.html#setting-the-locale-from-the-domain-name

module SetLocale
  extend ActiveSupport::Concern

  included do
    around_action :set_locale
  end

  def set_locale(&action)
    @pagy_locale = I18n.locale.to_s
    I18n.with_locale(find_locale, &action)
  end

  # Uncomment this if you'd like the locale included in URLs by default
  # def default_url_options
  #   { locale: I18n.locale }
  # end

  private

  def find_locale
    locale_from_params || locale_from_user || locale_from_header || I18n.default_locale
  end

  def locale_from_params
    permit_locale(params[:locale])
  end

  def locale_from_user
    return unless user_signed_in?
    permit_locale(current_user.preferred_language)
  end

  def locale_from_header
    # Extract the full locale (including region code)
    locale = request.env.fetch("HTTP_ACCEPT_LANGUAGE", "").scan(/^[a-z]{2}(?:-[A-Z]{2})?/).first
    permit_locale(locale)
  end

  # Makes sure locale is in the available locales list
  def permit_locale(locale)
    stripped_locale = locale&.strip
  
    if I18n.config.available_locales_set.include?(stripped_locale)
      stripped_locale
    else
      # Fallback to the 2 letter language code if the requested locale unavailable
      language_code = stripped_locale.to_s.split('-').first
      # Check if the two-letter language code is in the available locales
      I18n.config.available_locales_set.include?(language_code) ? language_code : nil
    end
  end
end
