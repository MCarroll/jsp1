require "pagy"
require "pagy/extras/trim"

module Jumpstart
  class Engine < ::Rails::Engine
    isolate_namespace Jumpstart
    engine_name "jumpstart"

    config.app_generators do |g|
      g.templates.unshift File.expand_path("../templates", __dir__)
      g.scaffold_stylesheet false
    end

    config.to_prepare do
      Administrate::ApplicationController.helper Jumpstart::AdministrateHelpers

      if Rails.env.development?
        ::ApplicationController.include(Jumpstart::Welcome)
        ::ApplicationController.include(Jumpstart::BundleAssets)
      end
    end

    initializer "turbo.native.navigation.helper" do
      ActiveSupport.on_load(:action_controller_base) do
        include Turbo::Native::Navigation
        helper Rails.application.helpers
      end
    end

    initializer "jumpstart.setup" do |app|
      if Rails.env.development?
        # This makes sure we can load the Jumpstart assets in development
        config.assets.precompile << "jumpstart_manifest.js"
      end

      if Jumpstart::Multitenancy.path? || Rails.env.test?
        app.config.middleware.use Jumpstart::AccountMiddleware
      end
    end

    initializer "jumpstart.sidekiq" do
      # Removable https://github.com/hotwired/turbo-rails/issues/522
      ::Sidekiq.strict_args!(false) if defined?(::Sidekiq)
    end
  end
end
