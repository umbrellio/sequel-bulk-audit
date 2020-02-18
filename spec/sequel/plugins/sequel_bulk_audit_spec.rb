# frozen_string_literal: true

require "spec_helper"
require 'pry'

RSpec.describe Sequel::Plugins::BulkAudit do
  before do
    class SimpleData < Sequel::Model(:data)
      plugin :bulk_audit
    end

    class SchemaData < Sequel::Model(Sequel[:public][:data])
      plugin :bulk_audit
    end
  end

  let!(:data_model) { SimpleData }

  let!(:current_user) do
    OpenStruct.new(login: 'UserLogin', id: 1)
  end

  let(:expectation) do
    {
      event:      event,
      model_type: model_name,
      user_id:    1,
      username:   "UserLogin",
      user_type:  "User",
      query:      a_string_starting_with(event),
      changed:    changed,
      model_id:   record.id.to_s,
    }
  end

  let(:model_name) { "SimpleData" }
  let(:changed)    { { "value" => record.value, "id" => record.id } }

  def with_audit_log
    data_model.with_current_user(current_user) { yield }
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

    let(:changed) { { "value" => ["6", "99"] } }

    include_examples "expect audit_log", "UPDATE"
  end

  context "when deleting old records" do
    let!(:record) { with_audit_log { data_model.last.delete } }

    include_examples "expect audit_log", "DELETE"
  end

  it "has a version number" do
    expect(Sequel::Plugins::BulkAudit::VERSION).not_to be nil
  end
end
