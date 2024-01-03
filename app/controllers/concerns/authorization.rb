module Authorization
  # Adds authorization with Pundit to controllers

  extend ActiveSupport::Concern
  include Pundit::Authorization

  included do
    # Uncomment to enforce Pundit authorization for every controller.
    # You will need to add `skip_after_action :verify_authorized` for public controllers.
    #
    # after_action :verify_authorized
    # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  end

  # Use AccountUser since it determines the roles for the current Account
  def pundit_user
    current_account_user
  end

  private

  # You can also customize the messages using the policy and action to generate the I18n key
  # https://github.com/varvet/pundit#creating-custom-error-messages
  def user_not_authorized
    redirect_back_or_to root_path, alert: t("unauthorized")
  end
end
