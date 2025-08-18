require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Code is reloaded any time it changes.
  config.cache_classes = false
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Allow all hosts in development (useful for Docker/compose).
  # Alternatively, set: config.hosts << "localhost" and your dev hostnames.
  config.hosts.clear

  # Serve static files from /public (handy in dev).
  config.public_file_server.enabled = true

  # Logging
  config.log_level = :debug
  config.logger = ActiveSupport::Logger.new($stdout)
  config.log_tags = [:request_id]

  # Don’t cache by default; toggle with rails dev:cache if needed.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Annotate rendered view with file names (nice for debugging).
  config.action_view.annotate_rendered_view_with_filenames = true

  # Suppress deprecation warnings noise in dev logs if desired:
  # config.active_support.report_deprecations = false
end