class Jumpstart::ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  impersonates :user

  # Used for sharing flash between main app and gem
  def current_account
  end
  helper_method :current_account
end
