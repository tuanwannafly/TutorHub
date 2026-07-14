Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  config.action_controller.perform_caching = false
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log

  config.active_record.migration_error = :page_load
  config.active_support.to_time_preserves_timezone = :zone

  config.action_mailer.perform_caching = false

  config.hosts.clear

  # Allow the React dev server (Vite on :5173) to call the API with cookies.
  config.action_dispatch.cookies_same_site_protection = :lax
end