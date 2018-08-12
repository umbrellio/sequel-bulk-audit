# frozen_string_literal: true

class AuditMigrationGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def copy_audit_migration_files
    version = Time.now.utc.strftime("%Y%m%d%H%M%S")
    copy_file "01_migration.rb", "db/migrate/#{version}_CreateAuditTableAndTrigger.rb"
  end
end
