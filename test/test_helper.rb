# test/test_helper.rb

# Freeze strings by default for consistency
# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

# Optional coverage: run tests with `COVERAGE=1 bundle exec rake test`
if ENV["COVERAGE"] == "1"
  begin
    require "simplecov"
    SimpleCov.start do
      enable_coverage :branch
      add_filter "/bin/"
      add_filter "/config/"
      add_filter "/db/"
      add_filter "/test/"
    end
  rescue LoadError
    warn "[test] simplecov not installed; skipping coverage"
  end
end

# Make sure bundler is set up
begin
  require "bundler/setup"
rescue LoadError
  warn "[test] bundler not found; proceeding without it"
end

# Load dotenv so ENV vars in .env/.env.test can be used by tests if desired
begin
  require "dotenv"
  if File.exist?(File.expand_path("../.env.test", __dir__))
    Dotenv.load(File.expand_path("../.env.test", __dir__))
  elsif File.exist?(File.expand_path("../.env", __dir__))
    Dotenv.load(File.expand_path("../.env", __dir__))
  end
rescue LoadError
  # dotenv is optional
end

# Try to load Rails' test helper if this is a Rails app
rails_loaded = false
begin
  require_relative "../config/environment"
  require "rails/test_help"
  rails_loaded = true
rescue LoadError
  # Not a Rails app or environment file not present; continue with plain Minitest
end

require "minitest/autorun"

# Optional nicer test output
begin
  require "minitest/reporters"
  Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
rescue LoadError
  # reporters are optional
end

if rails_loaded
  # Filter Rails' backtrace for readability
  Rails.backtrace_cleaner.remove_silencers!
  ActiveSupport::TestCase.parallelize(workers: :number_of_processors)
  # If ActiveRecord is used, uncomment the next line to run tests in parallel with DB
  # ActiveSupport::TestCase.parallelize(workers: :number_of_processors, with: :threads)
  ActiveSupport::TestCase.test_order = :random
else
  # Plain Minitest configuration
  Minitest::Test.parallelize_me!
  Minitest::Test.i_suck_and_my_tests_are_order_dependent! unless ENV["ORDER_INDEPENDENT"]
end

# Add test/support helpers automatically if present
support_glob = File.expand_path("support/**/*.rb", __dir__)
Dir[support_glob].sort.each { |f| require f }
