class ErrorsController < ApplicationController
  # Copy this file to your app directory to customize

  def not_found
    render status: 404
  end

  def internal_server_error
    render status: 500
  end
end
