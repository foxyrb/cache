# frozen_string_literal: true

require "spec_helper"

RSpec.describe Foxy::Cache::Store do
  [Foxy::Cache::Store::Memory, Foxy::Cache::Store::Fs].each do |store|
    context "store: #{store}" do
      subject do
        Foxy::Cache::Store::Namespace.new(
          namespace: "#{__dir__}/tmp/#{EXECUTION}",
          store: store.new
        )
      end

      after { subject.delete("/") }

      describe "#get" do
        it { expect(subject.get("/#{EXECUTION}")).to be_nil }

        it { expect(subject.get("/#{EXECUTION}.json")).to be_nil }
      end

      describe "#post" do
        it do
          subject.put("/POST/#{EXECUTION}", '{"k":"v"}')
          expect(subject.get("/POST/#{EXECUTION}")).to eq '{"k":"v"}'
        end

        it do
          subject.put("/POST/#{EXECUTION}.json", '{"k":"v"}')
          expect(subject.get("/POST/#{EXECUTION}.json")).to eq '{"k":"v"}'
        end
      end

      describe "#put" do
        it do
          subject.put("/PUT/#{EXECUTION}", '{"k":"v"}')
          expect(subject.get("/PUT/#{EXECUTION}")).to eq MultiJson.dump(k: :v)
        end

        it do
          subject.put("/PUT/#{EXECUTION}.json", '{"k":"v"}')
          expect(subject.get("/PUT/#{EXECUTION}.json")).to eq MultiJson.dump(k: :v)
        end
      end

      describe "#delete" do
        it "delete file" do
          expect(subject.get("/DELETE_FILE/#{EXECUTION}")).to be_nil
          subject.put("/DELETE_FILE/#{EXECUTION}", "content")
          expect(subject.get("/DELETE_FILE/#{EXECUTION}")).to eq "content"
          subject.delete("/DELETE_FILE/#{EXECUTION}")
          expect(subject.get("/DELETE_FILE/#{EXECUTION}")).to be_nil
        end

        it "delete folder" do
          expect(subject.get("/DELETE_FOLDER/#{EXECUTION}/file")).to be_nil
          subject.put("/DELETE_FOLDER/#{EXECUTION}/file", "content")
          expect(subject.get("/DELETE_FOLDER/#{EXECUTION}/file")).to eq "content"
          subject.delete("/DELETE_FOLDER/#{EXECUTION}")
          expect(subject.get("/DELETE_FOLDER/#{EXECUTION}/file")).to be_nil
        end
      end
    end
  end
end
