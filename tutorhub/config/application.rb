require_relative "boot"

require "rails"
# Pick only the frameworks we actually use.
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"

Bundler.require(*Rails.groups)

module Tutorhub
  class Application < Rails::Application
    config.load_defaults 7.1

    # Use SKU-style autoloading: app/services, app/queries, etc.
    config.autoload_paths += %W[
      #{config.root}/app/services
      #{config.root}/app/queries
    ]
    config.eager_load_paths += %W[
      #{config.root}/app/services
      #{config.root}/app/queries
    ]

    # I18n
    config.i18n.default_locale = :en

    # Timezone
    config.time_zone = "UTC"

    # ActiveJob adapter — swap to :sidekiq in production.
    config.active_job.queue_adapter = :async

    # Let the layout render even on prod with turbo-cache.
    config.action_controller.default_protect_from_forgery = true

    # Generate the credentials file only if missing.
    config.before_configuration do
      env_file = File.expand_path("../.env", __dir__)
      if File.exist?(env_file)
        File.foreach(env_file) do |line|
          next if line.strip.empty? || line.start_with?("#")
          key, value = line.strip.split("=", 2)
          ENV[key] ||= value
        end
      end
    end
  end
end
