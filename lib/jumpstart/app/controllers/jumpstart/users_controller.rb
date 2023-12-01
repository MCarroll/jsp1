require_dependency "jumpstart/application_controller"

module Jumpstart
  class UsersController < ApplicationController
    def index
      render json: User.where(admin: [nil, false]).where(User.arel_table[:email].matches("%#{User.sanitize_sql_like(params[:query])}%"))
    end

    def create
      user = User.find(params[:id])
      Jumpstart.grant_system_admin! user
      render turbo_stream: turbo_stream.append("admin_users", partial: "jumpstart/users/user", locals: {user: user})
    end
  end
end
