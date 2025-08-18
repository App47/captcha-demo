require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Cache classes and eager load for performance.
  config.cache_classes = true
  config.eager_load = true

  # Do not show full error reports in production.
  config.consider_all_requests_local = false

  # Host allowlist: set a comma-separated list in RAILS_ALLOWED_HOSTS.
  # Example: myapp.example.com,internal-alb-123.us-east-1.elb.amazonaws.com
  allowed_hosts = ENV.fetch("RAILS_ALLOWED_HOSTS", "").split(",").map(&:strip).reject(&:empty?)
  if allowed_hosts.any?
    config.hosts.clear
    allowed_hosts.each { |h| config.hosts << h }
  end

  # Serve static files from the /public folder if env set (typical in containers).
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Optional: force SSL if terminating at ALB and forwarding X-Forwarded-Proto.
  # Enable by setting FORCE_SSL=true
  config.force_ssl = ENV["FORCE_SSL"] == "true"

  # Logging to STDOUT for ECS/CloudWatch
  config.log_level = (ENV["RAILS_LOG_LEVEL"] || "info").to_sym
  logger           = ActiveSupport::Logger.new($stdout)
  logger.formatter = ::Logger::Formatter.new
  config.logger    = ActiveSupport::TaggedLogging.new(logger)
  config.log_tags  = [:request_id]

  # Caching
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store

  # Internationalization fallbacks
  config.i18n.fallbacks = true

  # Don’t dump schema (no DB in this app, but harmless)
  config.active_record.dump_schema_after_migration = false if defined?(ActiveRecord)

  # Set a default headers baseline; you can customize CSP if needed.
  # config.action_dispatch.default_headers = {
  #   "X-Frame-Options" => "SAMEORIGIN",
  #   "X-XSS-Protection" => "0",
  #   "X-Content-Type-Options" => "nosniff"
  # }

  # Optional CORS (if you expose endpoints to browsers from another origin)
  # Requires the rack-cors gem in your Gemfile (production group).
  if ENV["ALLOWED_CORS_ORIGINS"].present?
    origins = ENV["ALLOWED_CORS_ORIGINS"].split(",").map(&:strip)
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins origins
        resource "*",
                 headers: :any,
                 methods: %i[get post options],
                 expose: %w[Link],
                 max_age: 600
      end
    end
  end

  # Ensure SECRET_KEY_BASE is provided in production (required by Rails).
  if Rails.application.credentials.secret_key_base.blank? && ENV["SECRET_KEY_BASE"].to_s.strip.empty?
    warn "[config] SECRET_KEY_BASE is missing; set it in ENV or credentials."
  end
end