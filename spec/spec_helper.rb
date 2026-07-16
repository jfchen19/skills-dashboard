# frozen_string_literal: true

# Sinatra's Rack::Protection::HostAuthorization only allows "localhost"-like
# hosts in the default :development environment, which rejects Rack::Test's
# default "example.org" Host header. Setting :test (Sinatra's first-class
# test environment) disables that restriction and is the standard way to run
# Sinatra specs under rack-test.
ENV["RACK_ENV"] ||= "test"

FIXTURES = File.expand_path("fixtures", __dir__)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
