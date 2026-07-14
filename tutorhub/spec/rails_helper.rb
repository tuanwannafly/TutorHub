# frozen_string_literal: true

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

abort("Rails must be in test environment.") unless Rails.env.test?

require "rspec/rails"
require "factory_bot"
require "shoulda/matchers"
require "database_cleaner/active_record"
require_relative "support/login_helpers"

# Skip the auto-generated `lib` and `bin` loading that Rails usually does.
Rails.backtrace_cleaner.remove_silencers!

# Ensure test DB has schema loaded once before any specs run.
ActiveRecord::Base.connection.execute("SET search_path TO public")
load Rails.root.join('db/schema.rb').to_s if ActiveRecord::Base.connection.tables.empty?

RSpec.configure do |config|
  # We want all assertions to raise rather than print.
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.include FactoryBot::Syntax::Methods
  config.include LoginHelpers, type: :controller
  config.include LoginHelpers, type: :request

  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include Shoulda::Matchers::ActiveRecord, type: :model

  # We use `truncation` everywhere except service specs tagged
  # `:concurrency` — those intentionally exercise parallel writers, where a
  # shared transaction would mask the bug we're trying to catch.
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    if example.metadata[:concurrency]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end

    DatabaseCleaner.cleaning { example.run }
  end

  config.filter_rails_from_backtrace!

  # Tell Shoulda we're using RSpec so it skips the Test::Unit adapter.
  Shoulda::Matchers.configure do |shoulda_config|
    shoulda_config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
