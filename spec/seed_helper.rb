# frozen_string_literal: true

module SeedHelper
  class << self
    def prepare_data_table
      drop_data
      create_data
      seed_data
      restart_data_seq
      create_trigger_on_data
    end

    def create_data
      DB.create_table(:data) do
        primary_key :id
        String      :value
      end
    end

    def seed_data
      data = YAML.load(IO.read("spec/fixtures/data.yml"))
      DB[:data].multi_insert(data)
    end

    def restart_data_seq
      id = DB[:data].max(:id) + 1

      DB.execute(<<-SQL)
        ALTER SEQUENCE data_id_seq RESTART WITH #{id};
      SQL
    end

    def create_trigger_on_data
      DB.run <<~SQL
        CREATE TRIGGER audit_changes_on_data BEFORE INSERT OR UPDATE OR DELETE ON data
        FOR EACH ROW EXECUTE PROCEDURE audit_changes();
      SQL
    end

    def drop_data
      DB.drop_table?(:data)
    end

    def clear_audit_logs
      DB.tables.include?(:audit_logs) && DB[:audit_logs].truncate
    end
  end
end
