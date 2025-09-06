
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.session_store :cookie_store, secure: true
  config.cache_classes = true

  # Do not eager load code on boot.
  config.eager_load = true

  # Configure redis cache
  config.action_controller.perform_caching = false
  config.cache_store = :redis_store, RedisConfiguration.load(11)

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  # Show full error reports.
  config.consider_all_requests_local = true
  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :silence

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.public_file_server.enabled = true

  # Ruby
  config.log_level = :info

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    base = ActiveSupport::Logger.new($stdout)
    base.formatter = ::Logger::Formatter.new
    config.logger = ActiveSupport::TaggedLogging.new(base)
  end

  $stdout.sync = true
  $stderr.sync = true

  # Setup content security policy
  config.content_security_policy do |policy|
    policy.default_src :none
    policy.font_src    :self
    policy.img_src     :self, 'data:'
    policy.script_src  :self, 'https://js-agent.newrelic.com', 'https://bam.nr-data.net'
    policy.style_src   :self, 'https://cdnjs.cloudflare.com'
    policy.connect_src :self, 'https://bam.nr-data.net'
    policy.child_src   :self
  end

  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w(script-src)
end
