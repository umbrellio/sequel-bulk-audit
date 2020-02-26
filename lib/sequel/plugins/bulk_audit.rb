# frozen_string_literal: true

require "sequel/plugins/bulk_audit/version"
require "sequel/model"

module Sequel
  module Plugins
    module BulkAudit
      module ClassMethods
        def with_current_user(current_user, attributes = {})
          db.transaction do
            data = db.select(
              Sequel.expr(current_user&.id || 0).as(:user_id),
              Sequel.cast(current_user&.login || "unspecified", :text).as(:username),
              Sequel.expr(name).as(:model_name),
              Sequel.pg_array(stringified_columns).as(:columns),
              Sequel.pg_jsonb(attributes).as(:data),
            )

            create_temp_table(data)

            yield if block_given?
          end
        end

        def trid
          db.get(Sequel.function(:txid_current))
        end

        def create_temp_table(data)
          db.create_table!(audit_logs_temp_table_name, on_commit: :drop, temp: true, as: data)
        end

        def stringified_columns
          columns.map(&:to_s)
        end

        # uses trid so temp table would be unique between transactions
        # uses table_name so temp table would be unique if several models are audited at once
        def audit_logs_temp_table_name
          "__#{table_name_with_schema}_audit_info_#{trid}".to_sym
        end

        def table_name_with_schema
          return "public_#{table_name}" if table_name.is_a?(Symbol)

          "#{table_name.table}_#{table_name.column}" # for QualifiedIdentifier
        end
      end
    end
  end
end
