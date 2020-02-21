# frozen_string_literal: true

class SeedHelper
  attr_reader :table_name

  def self.clear_audit_logs
    DB.tables.include?(:audit_logs) && DB[:audit_logs].truncate
  end

  def initialize(table_name)
    @table_name = table_name.to_sym
  end

  def prepare_table
    drop_table
    create_table
    seed_table
    restart_table_seq
    create_trigger_on_table
  end

  def create_table
    DB.create_table(table_name) do
      primary_key :id
      String      :value
    end
  end

  def seed_table
    data = YAML.load(IO.read("spec/fixtures/data.yml"))
    DB[table_name].multi_insert(data)
  end

  def restart_table_seq
    id = DB[table_name].max(:id) + 1

    DB.execute(<<-SQL)
      ALTER SEQUENCE #{table_name}_id_seq RESTART WITH #{id};
    SQL
  end

  def create_trigger_on_table
    DB.run <<~SQL
      CREATE TRIGGER audit_changes_on_#{table_name}
      BEFORE INSERT OR UPDATE OR DELETE ON #{table_name}
      FOR EACH ROW EXECUTE PROCEDURE audit_changes();
    SQL
  end

  def drop_table
    DB.drop_table?(table_name)
  end
end
