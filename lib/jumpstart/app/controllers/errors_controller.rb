class ErrorsController < ApplicationController
  # Copy this file to your app directory to customize

  def not_found
    respond_to do |format|
      format.json { render status: :not_found }
      format.any { render status: :not_found, formats: :html }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.json { render status: :internal_server_error }
      format.any { render status: :internal_server_error, formats: :html }
    end
  end
end
