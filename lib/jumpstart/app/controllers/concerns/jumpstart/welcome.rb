module Jumpstart::Welcome
  extend ActiveSupport::Concern

  included do
    prepend_before_action :jumpstart_welcome, if: -> { Rails.env.development? }
  end

  def jumpstart_welcome
    redirect_to jumpstart.root_path(welcome: true) unless Rails.root.join("config/jumpstart.yml").exist?
  end
end
