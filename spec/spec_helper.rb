# frozen_string_literal: true

require "simplecov"
require "coveralls"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter,
])

SimpleCov.start { add_filter "spec" }

require "bundler/setup"
require "sequel"
require "sequel/extensions/migration"
require "sequel-bulk-audit"
require "sequel/plugins/bulk_audit"
require "yaml"
require "pry"

require_relative "support/database_setup"
require_relative "support/table_scope"

DB = SpecSupport::DatabaseSetup.connect

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.before(:all) { SpecSupport::TableScope.build(DB) }
  config.after(:all)  { SpecSupport::TableScope.clear(DB) }
end
