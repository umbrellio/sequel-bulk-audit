# frozen_string_literal: true

module SpecSupport
  module TableScope
    extend self

    def build(connection)
      data = YAML.load(IO.read("spec/fixtures/data.yml"))
      connection.drop_table?(:data)

      connection.create_table(:data) do
        primary_key :id
        DateTime :created_at
        DateTime :updated_at
        String :value
      end

      connection[:data].multi_insert(data)
      id = connection[:data].max(:id) + 1

      connection.execute(<<-SQL)
        ALTER SEQUENCE data_id_seq RESTART WITH #{id};
      SQL

      connection.run <<~SQL
        CREATE TRIGGER audit_changes_on_data BEFORE INSERT OR UPDATE OR DELETE ON data
        FOR EACH ROW EXECUTE PROCEDURE audit_changes();
      SQL
    end

    def clear(connection)
      connection.drop_table?(:data)
    end
  end
end
