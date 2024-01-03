class Api::V1::AuthsController < Api::BaseController
  skip_before_action :authenticate_api_token!, only: [:create]
  before_action :authenticate, only: [:create]

  # Requires email and password params
  # Turbo Native requests should sign in user with cookie for browser authentication
  # Returns an API token for the user if valid
  def create
    if turbo_native_app?
      sign_in_user
      render json: {token: token_by_name(ApiToken::APP_NAME)}
    else
      render json: {token: token_by_name(ApiToken::DEFAULT_NAME)}
    end
  end

  def destroy
    notification_token&.destroy
    sign_out(current_user)
    render json: {}
  end

  private

  # Authenticates email and password
  # Then if OTP require but not present, sends 422 response
  def authenticate
    if !user&.valid_password?(params[:password])
      render json: {error: error_message}, status: :unauthorized
    elsif !user.otp_required_for_login?
      true
    elsif params[:otp_attempt].blank?
      render json: {error: :otp_attempt_required}, status: :unprocessable_entity
    elsif user.verify_and_consume_otp!(params[:otp_attempt])
      true
    else
      render json: {error: t("users.sessions.create.incorrect_verification_code")}, status: :unauthorized
    end
  end

  def user
    @user ||= User.find_by(email: params[:email])
  end

  def sign_in_user
    user.remember_me = true
    sign_in user
  end

  def token_by_name(name)
    user.api_tokens.find_or_create_by(name: name).token
  end

  def error_message
    keys = User.authentication_keys.join(I18n.translate(:"support.array.words_connector"))
    I18n.t("devise.failure.invalid", authentication_keys: keys)
  end

  def notification_token
    current_user.notification_tokens.find_by(token: params[:notification_token])
  end
end
