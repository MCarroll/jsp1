module Jumpstart
  class JobProcessor
    AVAILABLE_PROVIDERS = {
      "Async" => :async,
      "Sidekiq" => :sidekiq,
      "DelayedJob" => :delayed_job,
      "Sneakers" => :sneakers,
      "SuckerPunch" => :sucker_punch,
      "Que" => :que,
      "GoodJob" => :good_job,
      "SolidQueue" => :solid_queue
    }.freeze

    AVAILABLE_PROVIDERS.each do |_, name|
      define_singleton_method :"#{name}?" do
        Jumpstart.config.job_processor == name
      end
    end

    def self.command(processor)
      # async, sucker_punch don't need separate processes
      case processor.to_s
      when "sidekiq"
        "bundle exec sidekiq"
      when "delayed_job"
        "QUEUES=default,mailers,action_mailbox_incineration,action_mailbox_routing,active_storage_analysis,active_storage_purge bundle exec rake delayed:work"
      when "sneakers"
        "rake sneakers:run"
      when "que"
        "bundle exec que -q default -q mailers -q action_mailbox_incineration -q action_mailbox_routing -q active_storage_analysis -q active_storage_purge"
      when "good_job"
        "bundle exec good_job start"
      when "solid_queue"
        "bundle exec rake solid_queue:start"
      end
    end
  end
end
