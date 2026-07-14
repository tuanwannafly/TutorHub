# frozen_string_literal: true

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.warnings = false

  # Most RSpec core code is thread-safe, but a few helpers (notably
  # `before(:context)` evaluation) need a lock.
  config.order = :random
  Kernel.srand config.seed

  # Run only `:focus` examples when filtering with `fit`/`fdescribe`. We
  # always-on `--tag ~slow` so the default suite is fast.
  config.define_derived_metadata(file_path: %r{/spec/}) do |metadata|
    metadata[:type] ||= :example
  end
  config.filter_run_excluding :slow
end
