# frozen_string_literal: true

module SpecSupport
  module DatabaseSetup
    extend self

    DB_NAME = (ENV["DB_NAME"] || "audit_test").freeze

    def connect
      Sequel.connect("postgres:///#{DB_NAME}").tap do |connection|
        post_init(connection)
      end
    rescue Sequel::DatabaseConnectionError => e
      raise unless e.message.include? "database \"#{DB_NAME}\" does not exist"
      Sequel.connect("postgres:///postgres") do |connection|
        connection.run("create database #{DB_NAME}")
      end
      Sequel.connect("postgres:///#{DB_NAME}").tap do |connection|
        post_init(connection)
      end
    end

    def post_init(connection)
      Sequel.extension :core_extensions
      connection.extension :pg_json
      Sequel::Migrator.run(connection, "lib/generators/audit_migration/templates")
    end
  end
end
