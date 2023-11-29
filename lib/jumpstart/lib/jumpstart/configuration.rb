require_relative "configuration/mailable"
require_relative "configuration/integratable"
require_relative "configuration/payable"
require_relative "yaml_serializer"

# Gems cannot be loaded here since this runs during bundler/setup

module Jumpstart
  def self.config
    @config ||= Configuration.load!
  end

  def self.config=(value)
    @config = value
  end

  class Configuration
    include Mailable
    include Integratable
    include Payable

    # Attributes
    attr_accessor :application_name
    attr_accessor :business_name
    attr_accessor :business_address
    attr_accessor :domain
    attr_accessor :background_job_processor
    attr_accessor :email_provider
    attr_accessor :default_from_email
    attr_accessor :support_email
    attr_accessor :multitenancy
    attr_accessor :apns
    attr_accessor :fcm
    attr_writer :gems
    attr_writer :omniauth_providers

    def self.load!
      if File.exist?(config_path)
        new(YAMLSerializer.load(config_path)).apply_upgrades
      else
        new
      end
    end

    def self.config_path
      File.join("config", "jumpstart.yml")
    end

    def self.create_default_config
      FileUtils.cp File.join(File.dirname(__FILE__), "../templates/jumpstart.yml"), config_path
    end

    def initialize(options = {})
      @application_name = options["application_name"] || "My App"
      @business_name = options["business_name"] || "My Company, LLC"
      @business_address = options["business_address"] || ""
      @domain = options["domain"] || "example.com"
      @support_email = options["support_email"] || "support@example.com"
      @default_from_email = options["default_from_email"] || "My App <no-reply@example.com>"
      @background_job_processor = options["background_job_processor"] || "async"
      @email_provider = options["email_provider"]

      @personal_accounts = cast_to_boolean(options["personal_accounts"]) || true
      @register_with_account = cast_to_boolean(options["register_with_account"]) || false
      @collect_billing_address = cast_to_boolean(options["collect_billing_address"])

      @apns = cast_to_boolean(options["apns"])
      @fcm = cast_to_boolean(options["fcm"])
      @integrations = options.fetch("integrations", [])
      @omniauth_providers = options.fetch("omniauth_providers", [])
      @payment_processors = options.fetch("payment_processors", [])
      @multitenancy = options.fetch("multitenancy", [])
      @gems = options.fetch("gems", [])
    end

    def apply_upgrades
      if @payment_processors&.include? "paddle"
        @payment_processors.delete "paddle"
        @payment_processors << "paddle_classic"
        write_config
      end
      self
    end

    def write_config
      YAMLSerializer.dump_to_file(self.class.config_path, self)
    end

    def save
      write_config
      update_procfiles
      copy_configs
      generate_credentials

      # Change the Jumpstart config to the latest version
      Jumpstart.config = self
    end

    def job_processor
      (background_job_processor || "async").to_sym
    end

    def gems
      Array(@gems)
    end

    def omniauth_providers
      Array(@omniauth_providers)
    end

    def register_with_account=(value)
      @register_with_account = cast_to_boolean(value)
    end

    def register_with_account?
      @register_with_account.nil? ? false : cast_to_boolean(@register_with_account)
    end

    def personal_accounts=(value)
      @personal_accounts = cast_to_boolean(value)
    end

    def personal_accounts
      # Enabled by default
      @personal_accounts.nil? ? true : cast_to_boolean(@personal_accounts)
    end

    def apns?
      cast_to_boolean(@apns || false)
    end

    def fcm?
      cast_to_boolean(@fcm || false)
    end

    def collect_billing_address=(value)
      @collect_billing_address = cast_to_boolean(value)
    end

    def collect_billing_address?
      cast_to_boolean(@collect_billing_address || false)
    end

    def update_procfiles
      write_procfile Rails.root.join("Procfile"), procfile_content
      write_procfile Rails.root.join("Procfile.dev"), procfile_content(dev: true)
    end

    def copy_configs
      if job_processor == :sidekiq
        copy_template("config/sidekiq.yml")
      end

      if airbrake?
        copy_template("config/initializers/airbrake.rb")
      end

      if appsignal?
        copy_template("config/appsignal.yml")
      end

      if bugsnag?
        copy_template("config/initializers/bugsnag.rb")
      end

      if convertkit?
        copy_template("config/initializers/convertkit.rb")
      end

      if drip?
        copy_template("config/initializers/drip.rb")
      end

      if honeybadger?
        copy_template("config/honeybadger.yml")
      end

      if intercom?
        copy_template("config/initializers/intercom.rb")
      end

      if mailchimp?
        copy_template("config/initializers/mailchimp.rb")
      end

      if rollbar?
        copy_template("config/initializers/rollbar.rb")
      end

      if scout?
        copy_template("config/scout_apm.yml")
      end

      if sentry?
        copy_template("config/initializers/sentry.rb")
      end

      if skylight?
        copy_template("config/skylight.yml")
      end
    end

    def generate_credentials
      %w[test development staging production].each do |env|
        key_path = Pathname.new("config/credentials/#{env}.key")
        credentials_path = "config/credentials/#{env}.yml.enc"

        # Skip generating if credentials file already exists
        next if File.exist?(credentials_path)

        Rails::Generators::EncryptionKeyFileGenerator.new.add_key_file_silently(key_path)
        Rails::Generators::EncryptionKeyFileGenerator.new.ignore_key_file_silently(key_path)
        Rails::Generators::EncryptedFileGenerator.new.add_encrypted_file_silently(credentials_path, key_path, Jumpstart::Credentials.template)

        # Add the credentials if we're in a git repo
        if File.directory?(".git")
          system("git add #{credentials_path}")
        end
      end
    end

    def model_name
      ActiveModel::Name.new(self, nil, "Configuration")
    end

    def persisted?
      false
    end

    private

    def procfile_content(dev: false)
      content = {web: "bundle exec rails s"}

      # Background workers
      if (worker_command = Jumpstart::JobProcessor.command(job_processor))
        content[:worker] = worker_command
      end

      # Add the Stripe CLI
      content[:stripe] = "stripe listen --forward-to localhost:3000/webhooks/stripe" if dev && stripe?

      content
    end

    def write_procfile(path, commands)
      commands.each do |name, command|
        new_line = "#{name}: #{command}"

        if (matches = File.foreach(path).grep(/#{name}:/)) && matches.any?
          # Warn only if lines don't match
          if (old_line = matches.first.chomp) && old_line != new_line
            Rails.logger.warn "\n'#{name}' already exists in #{path}, skipping. \nOld: `#{old_line}`\nNew: `#{new_line}`\n"
          end
        else
          File.open(path, "a") { |f| f.write("#{name}: #{command}\n") }
        end
      end
    end

    def copy_template(filename)
      # Safely copy template, so we don't blow away any customizations you made
      unless File.exist?(filename)
        FileUtils.cp(template_path(filename), Rails.root.join(filename))
      end
    end

    def template_path(filename)
      Rails.root.join("lib/templates", filename)
    end

    FALSE_VALUES = [
      false, 0,
      "0", :"0",
      "f", :f,
      "F", :F,
      "false", # :false,
      "FALSE", :FALSE,
      "off", :off,
      "OFF", :OFF
    ].freeze

    def cast_to_boolean(value)
      if value.nil? || value == ""
        nil
      else
        !FALSE_VALUES.include?(value)
      end
    end
  end
end
