Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  # The default file store can't rename locked files on Windows, which breaks rate limiting.
  config.cache_store = :memory_store

  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  config.action_view.annotate_rendered_view_with_filenames = true
end
