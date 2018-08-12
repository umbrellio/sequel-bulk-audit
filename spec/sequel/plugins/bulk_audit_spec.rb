# frozen_string_literal: true

RSpec.describe Sequel::Plugins::BulkAudit do
  before do
    Sequel::Model.plugin :bulk_audit
    DB.tables.include?(:audit_logs) && DB[:audit_logs].truncate
  end

  let!(:audit_model) do
    class AuditLog < Sequel::Model
      plugin :polymorphic
      many_to_one :model, polymorphic: true
    end
  end

  let!(:model) do
    Class.new(Sequel::Model(:data)) do
      plugin :bulk_audit
    end
  end

  let!(:current_user) do
    OpenStruct.new(login: "UserLogin", id: 1)
  end

  it "prepares data" do
    expect(model.count).to eq(6)
  end

  it "creates data" do
    model.with_current_user(current_user) do
      model.create(value: 5)
    end
    expect(DB[:audit_logs].count).to eq(1)
    expect(DB[:audit_logs].all).to include(
      a_hash_including(
        event: "INSERT",
        username: "UserLogin",
        user_type: "User",
        query: a_string_starting_with("INSERT"),
        changed: an_object_having_attributes(
          to_h: a_hash_including(
            "value" => "5",
          ),
        ),
      ),
    )
    model.with_current_user(current_user) do
      model.last.destroy
    end
    expect(DB[:audit_logs].count).to eq(2)
    expect(DB[:audit_logs].all).to include(
      a_hash_including(
        event: "DELETE",
        username: "UserLogin",
        user_type: "User",
        query: a_string_starting_with("DELETE"),
        changed: an_object_having_attributes(
          to_h: a_hash_including(
            "value" => "5",
          ),
        ),
      ),
    )
  end

  it "updates data" do
    model.with_current_user(current_user) do
      model.where("1=1".lit).update(value: "new_value")
    end
    expect(DB[:audit_logs].count).to eq(6)
    expect(DB[:audit_logs].all).to include(
      a_hash_including(
        event: "UPDATE",
        username: "UserLogin",
        user_type: "User",
        query: a_string_starting_with("UPDATE"),
        changed: an_object_having_attributes(
          to_h: a_hash_including(
            "value" => %w[3 new_value],
          ),
        ),
      ),
      a_hash_including(
        event: "UPDATE",
        username: "UserLogin",
        user_type: "User",
        query: a_string_starting_with("UPDATE"),
        changed: an_object_having_attributes(
          to_h: a_hash_including(
            "value" => %w[4 new_value],
          ),
        ),
      ),
    )
  end

  it "destroys data" do
    model.with_current_user(current_user) do
      model.where("1=1".lit).delete
    end
    expect(DB[:audit_logs].count).to eq(6)
  end

  it "builds an association to audit log" do
    class MyData < Sequel::Model(:data)
      plugin :polymorphic
      one_to_many :audit_logs, as: :model
    end
    MyData.class_variable_set(:@@model_to_table_map, nil)
    rec = model.with_current_user(current_user) do
      MyData.create(value: 5)
    end
    expect(rec).to be_instance_of(MyData)

    expect(DB[:audit_logs].all).to include(
      a_hash_including(
        event: "INSERT",
        username: "UserLogin",
        user_type: "User",
        model_type: "MyData",
        model_id: rec.id.to_s,
        query: a_string_starting_with("INSERT"),
        changed: an_object_having_attributes(
          to_h: a_hash_including(
            "value" => "5",
          ),
        ),
      ),
    )
    expect(AuditLog.all.first.model.value).to eq("5")
    expect(AuditLog.all.first.model.id).to eq(rec.id)
    Object.send(:remove_const, :Data)
  end

  it "has a version number" do
    expect(Sequel::Plugins::BulkAudit::VERSION).not_to be nil
  end
end
