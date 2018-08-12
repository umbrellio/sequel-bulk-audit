# frozen_string_literal: true

require "sequel/plugins/bulk_audit/version"
require "sequel/model"

module Sequel
  module Plugins
    module BulkAudit
      def self.apply(model, opts = {})
        model.instance_eval do
          @excluded_columns = [*opts[:excluded_columns]]
        end
      end

      module SharedMethods
        def model_to_table_map
          # rubocop:disable Style/ClassVars, Style/MultilineBlockChain
          @@model_to_table_map ||= ObjectSpace.each_object(Class).select do |klazz|
            next if klazz.name.nil?
            klazz < Sequel::Model && klazz&.plugins&.include?(Sequel::Plugins::BulkAudit)
          end.map { |c| [c.to_s, c.table_name] }.to_h.invert
          # rubocop:enable Style/ClassVars, Style/MultilineBlockChain
        end

        def with_current_user(current_user, attributes = nil)
          db.transaction do
            trid = db.select(Sequel.function(:txid_current)).single_value
            data = db.select(Sequel.expr(current_user&.id || 0).as(:user_id),
                             Sequel.cast(current_user&.login || "unspecified", :text).as(:username),
                             Sequel.pg_jsonb(model_to_table_map).as(:model_map),
                             Sequel.pg_jsonb(attributes || {}).as(:data))
            db.create_table!(:"__audit_info_#{trid}", temp: true, as: data)
            result = yield if block_given?
            db.drop_table?(:"__audit_info_#{trid}")
            result
          end
        end
      end

      module ClassMethods
        include SharedMethods
      end

      module InstanceMethods
        include SharedMethods
      end
    end
  end
end
