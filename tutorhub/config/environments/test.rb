Rails.application.configure do
  config.cache_classes = true
  config.eager_load = false

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions  = :rescuable
  config.action_controller.allow_forgery_protection = false

  config.active_support.deprecation = :stderr

  config.action_mailer.raise_delivery_errors = true

  config.active_job.queue_adapter = :test
  config.active_support.to_time_preserves_timezone = :zone

  config.secret_key_base = "test-secret-key-base-not-for-production"
end
