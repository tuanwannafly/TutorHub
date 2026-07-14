Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false

  config.active_record.dump_schema_after_migration = false
  config.active_record.dump_schemas_on_db_setup = false

  config.action_controller.perform_caching = true
  config.active_support.to_time_preserves_timezone = :zone

  config.log_level = :info

  config.action_mailer.perform_caching = false
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  config.active_job.queue_adapter = ENV.fetch("JOB_ADAPTER", "async")
end
