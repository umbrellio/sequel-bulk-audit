# frozen_string_literal: true

require "bundler/setup"
require "sequel"
require "sequel/extensions/migration"
require "sequel_bulk_audit"
require "sequel/plugins/bulk_audit"
require "seed_helper"
require "yaml"

DB_NAME = (ENV["DB_NAME"] || "audit_test").freeze

def connect
  Sequel.connect("postgres:///#{DB_NAME}")
rescue Sequel::DatabaseConnectionError => error
  raise unless error.message.include? "database \"#{DB_NAME}\" does not exist"
  Sequel.connect("postgres:///postgres") do |connect|
    connect.run("create database #{DB_NAME}")
  end
  Sequel.connect("postgres:///#{DB_NAME}")
end

DB = connect

Sequel.extension :core_extensions

DB.extension :pg_json
DB.extension :pg_array

::Sequel::Migrator.run(DB, "lib/generators/audit_migration/templates")

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    SeedHelper.clear_audit_logs
    SeedHelper.new(:data).prepare_table
  end
end
