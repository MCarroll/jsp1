require "test_helper"

Dir["#{File.dirname(__FILE__)}/support/system/**/*.rb"].sort.each { |f| require f }

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Backport
  def self.served_by(host:, port:)
    Capybara.server_host = host
    Capybara.server_port = port
  end

  if ENV["CAPYBARA_SERVER_PORT"]
    served_by host: "rails-app", port: ENV["CAPYBARA_SERVER_PORT"]

    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ], options: {
      browser: :remote,
      url: "http://#{ENV["SELENIUM_HOST"]}:4444"
    }
  else
    driven_by :selenium, using: ENV.fetch("DRIVER", :headless_chrome).to_sym, screen_size: [1400, 1400]
  end

  include Warden::Test::Helpers
  include TrixSystemTestHelper

  def switch_account(account)
    visit test_switch_account_url(account)
  end
end

Capybara.default_max_wait_time = 10

# Add a route for easily switching accounts in system tests
Rails.application.routes.append do
  get "/accounts/:id/switch", to: "accounts#switch", as: :test_switch_account
end
Rails.application.reload_routes!
