# frozen_string_literal: true

require "spec_helper"
require "pry"

RSpec.describe Sequel::Plugins::BulkAudit do
  before do
    stub_const("SimpleData", class_with_bulk_audit(:data))
    stub_const("SchemaData", class_with_bulk_audit(Sequel[:public][:data]))
  end

  let!(:data_model) { SimpleData }

  let!(:current_user) do
    OpenStruct.new(login: "UserLogin", id: 1)
  end

  let(:expectation) do
    {
      event: event,
      model_type: model_name,
      user_id: 1,
      username: "UserLogin",
      user_type: "User",
      query: a_string_starting_with(event),
      changed: changed,
      model_id: record.id.to_s,
    }
  end

  let(:model_name) { "SimpleData" }
  let(:changed)    { { "value" => record.value, "id" => record.id } }

  def with_audit_log
    data_model.with_current_user(current_user) { yield }
  end

  def class_with_bulk_audit(table)
    Class.new(Sequel::Model(table)) { plugin :bulk_audit }
  end

  shared_examples "expect audit_log" do |event|
    let(:event) { event }

    specify { expect(DB[:audit_logs].all).to include(a_hash_including(expectation)) }
  end

  context "pre-test preparations" do
    it "seeds data" do
      expect(data_model.count).to eq(6)
    end
  end

  context "when inserting new records" do
    let!(:record) { with_audit_log { data_model.create(value: "50") } }

    include_examples "expect audit_log", "INSERT"

    context "model with quilified identifier" do
      let(:data_model) { SchemaData }
      let(:model_name) { "SchemaData" }

      include_examples "expect audit_log", "INSERT"
    end
  end

  context "when updating records" do
    let!(:record) { with_audit_log { data_model.last.update(value: "99") } }

    let(:changed) { { "value" => %w[6 99] } }

    include_examples "expect audit_log", "UPDATE"
  end

  context "when deleting old records" do
    let!(:record) { with_audit_log { data_model.last.delete } }

    include_examples "expect audit_log", "DELETE"
  end

  context "with several models" do
    before do
      SeedHelper.new(:data_2).prepare_table

      stub_const("OtherData", class_with_bulk_audit(:data_2))
    end

    let(:simple_data) { SimpleData.create(value: "50") }
    let(:other_data)  { OtherData.create(value: "100") }

    it "correctly creates audit logs in one transaction" do
      expect(DB[:audit_logs].count).to eq(0)

      DB.transaction do
        SimpleData.with_current_user(current_user) { simple_data } # log for SimpleData
        OtherData.with_current_user(current_user)  { other_data }  # log for OtherData
      end

      expect(DB[:audit_logs].all).to include(
        a_hash_including(
          event: "INSERT",
          model_type: "SimpleData",
          changed: { "id" => simple_data.id, "value" => "50" },
        ),
        a_hash_including(
          event: "INSERT",
          model_type: "OtherData",
          changed: { "id" => other_data.id, "value" => "100" },
        ),
      )
    end

    context "auditing incorrect model" do
      let(:error_message) do
        a_string_including('PG::UndefinedTable: ERROR:  relation "__public_data_audit_info_')
      end

      it "raises error" do
        expect do
          OtherData.with_current_user(current_user) { simple_data }
        end.to raise_error(Sequel::DatabaseError).with_message(error_message)
      end
    end
  end

  it "has a version number" do
    expect(Sequel::Plugins::BulkAudit::VERSION).not_to be nil
  end
end
