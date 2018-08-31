# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sequel/plugins/bulk_audit/version"

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.3.7'

  spec.name        = "sequel-bulk-audit"
  spec.version     = Sequel::Plugins::BulkAudit::VERSION
  spec.authors     = ["Fox"]
  spec.email       = ["strong.drug@gmail.com"]
  spec.license     = "MIT"
  spec.homepage    = "https://github.com/fiscal-cliff/sequel-bulk-audit/"
  spec.summary     = "This gem provides a trigger based solution for auditing table changes"
  spec.description = "Every update on audited table will be logged. " \
                     "You can update the table in bulk"

  spec.post_install_message = "Next steps: " \
                              "1. Run rails g audit_migration " \
                              "2. Edit generated migration " \
                              "3. Apply the migration"

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.add_dependency "pg",     ">= 0.17.0"
  spec.add_dependency "sequel", ">= 4.0.0"

  spec.add_development_dependency "coveralls",                "~> 0.8"
  spec.add_development_dependency "simplecov",                "~> 0.16"
  spec.add_development_dependency "bundler",                  "~> 1.16"
  spec.add_development_dependency "pry",                      "~> 0.11"
  spec.add_development_dependency "rake",                     "~> 12.3"
  spec.add_development_dependency "rspec",                    "~> 3.8"
  spec.add_development_dependency "rubocop-config-umbrellio", "~> 0.52"
  spec.add_development_dependency "sequel_polymorphic",       "~> 0.4"
end
