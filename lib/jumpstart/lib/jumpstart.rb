require "jumpstart/engine"

module Jumpstart
  autoload :AccountMiddleware, "jumpstart/account_middleware"
  autoload :AdministrateHelpers, "jumpstart/administrate_helpers"
  autoload :Configuration, "jumpstart/configuration"
  autoload :JobProcessor, "jumpstart/job_processor"
  autoload :Mailer, "jumpstart/mailer"
  autoload :Mentions, "jumpstart/mentions"
  autoload :Multitenancy, "jumpstart/multitenancy"
  autoload :Omniauth, "jumpstart/omniauth"
  autoload :SubscriptionExtensions, "jumpstart/subscription_extensions"

  def self.restart
    run_command "rails restart"
  end

  # https://stackoverflow.com/a/25615344/277994
  def self.bundle
    run_command "bundle"
  end

  def self.run_command(command)
    Bundler.with_original_env do
      system command
    end
  end

  def self.find_plan(id)
    return if id.nil?
    config.plans.find { |plan| plan["id"].to_s == id.to_s }
  end

  def self.processor_plan_id_for(id, interval, processor)
    find_plan(id)[interval]["#{processor}_id"]
  end

  def self.credentials
    Rails.application.credentials
  end

  # Commands to be run after bundle install
  def self.post_install
    if JobProcessor.delayed_job? && !Dir[Rails.root.join("db/migrate/**/*delayed_jobs*")].any?
      run_command("rails generate delayed:migration")
      run_command("rails db:migrate")
    end

    if JobProcessor.good_job? && !Dir[Rails.root.join("db/migrate/**/*good_jobs*")].any?
      run_command("rails generate good_job:install")
      run_command("rails db:migrate")
    end

    if JobProcessor.solid_queue? && !Dir[Rails.root.join("db/migrate/**/*solid_queue*")].any?
      run_command("rails generate solid_queue:install")
      run_command("rails db:migrate")
    end

    if config.gems.include?("refer") && !Dir[Rails.root.join("db/migrate/**/*refer*.refer.rb")].any?
      run_command("rails refer:install:migrations")
    end
  end

  def self.grant_system_admin!(user)
    User.connection.execute("UPDATE users SET admin=true WHERE users.id='#{user.id}'")
    user.reload
  end

  def self.revoke_system_admin!(user)
    User.connection.execute("UPDATE users SET admin=false WHERE users.id='#{user.id}'")
    user.reload
  end
end
