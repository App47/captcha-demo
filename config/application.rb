# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module ResetDemo
  class Application < Rails::Application
    config.load_defaults 7.2
    config.time_zone = "UTC"
    config.eager_load = ENV["RAILS_ENV"] == "production"

    config.eager_load_paths << Rails.root.join("app/services")
    config.autoload_paths << Rails.root.join("app/services")

    config.generators do |g|
      g.orm :none
      g.assets false
      g.helper false
      g.stylesheets false
      g.javascripts false
      g.system_tests nil
      g.test_framework nil
    end
  end
end