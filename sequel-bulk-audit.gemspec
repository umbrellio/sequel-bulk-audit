# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sequel/plugins/bulk_audit/version"

Gem::Specification.new do |spec|
  spec.name          = "sequel-bulk-audit"
  spec.version       = Sequel::Plugins::BulkAudit::VERSION
  spec.authors       = ["Fox"]
  spec.email         = ["strong.drug@gmail.com"]

  spec.summary       = %q{This gem provides a trigger based solution for auditing table changes}
  spec.description   = %q{Every update on audited table will be logged. You can update the table in bulk}
  spec.homepage      = "https://github.com/fiscal-cliff/sequel-bulk-audit/"
  spec.post_install_message = %q{ Next steps:
    1. Run rails g audit_migration
    2. Edit generated migration
    3. Apply the migration"
  }

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sequel", ">= 4.0.0"
  spec.add_dependency "pg", ">= 0.17.0"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "sequel_polymorphic"
end
