class Users::ReferralsController < ApplicationController
  before_action :authenticate_user!

  def index
    @referral_code = current_user.referral_codes.first_or_create
  end
end
